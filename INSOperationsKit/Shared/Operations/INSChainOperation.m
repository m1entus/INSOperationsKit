//
//  INSChainOperation.m
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 07.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import "INSChainOperation.h"
#import "INSOperationQueue.h"

@interface INSChainOperation () <INSOperationQueueDelegate>
@property (nonatomic, strong) INSOperationQueue *internalQueue;
@property (nonatomic, copy) NSBlockOperation *finishingOperation;
@property (nonatomic, strong) NSMutableArray /*NSError*/ *aggregatedErrors;
@property (nonatomic, strong) NSArray <NSOperation *> *operations;
@end

@implementation INSChainOperation

+ (instancetype)operationWithOperations:(NSArray <NSOperation <INSChainableOperationProtocol> *>*)operations {
    return [[[self class] alloc] initWithOperations:operations];
}

- (instancetype)initWithOperations:(NSArray <NSOperation <INSChainableOperationProtocol> *>*)operations {
    if (self = [super init]) {
        _finishIfProducedAnyError = YES;
        _finishingOperation = [NSBlockOperation blockOperationWithBlock:^{}];
        _aggregatedErrors = [NSMutableArray array];
        _internalQueue = [[INSOperationQueue alloc] init];
        _internalQueue.maxConcurrentOperationCount = 1;
        _internalQueue.suspended = YES;
        _internalQueue.delegate = self;
        _operations = operations ?: @[];
    }
    return self;
}

- (void)cancel {
    [self.internalQueue cancelAllOperations];
    self.internalQueue.suspended = NO;
    [super cancel];
}

- (void)execute {
    if (self.operations.count <= 0) {
        [self finish];
        return;
    }
    
    NSOperation *dependencyOperation = nil;
    for (NSOperation *op in self.operations) {
        if (dependencyOperation) {
            [op addDependency:dependencyOperation];
        }
        [_internalQueue addOperation:op];
        dependencyOperation = op;
    }
    
    [self.internalQueue addOperation:self.finishingOperation];
    self.internalQueue.suspended = NO;
}

- (void)addOperation:(NSOperation *)operation {
    if ([self isCancelled] || [self isFinished]) {
        return;
    }
    NSParameterAssert(self.state < INSOperationStateExecuting);
    
    self.operations = [self.operations arrayByAddingObject:operation];
}

/**
 Note that some part of execution has produced an error.
 Errors aggregated through this method will be included in the final array
 of errors reported to observers and to the `finished(_:)` method.
 */
- (void)aggregateError:(NSError *)error {
    [self.aggregatedErrors addObject:error];
}

- (void)operationDidFinish:(NSOperation *)operation withErrors:(NSArray <NSError *> *)errors {
    
    NSInteger nextOperationIndex = [self.internalQueue.operations indexOfObject:operation] + 1;
    if (self.internalQueue.operationCount > nextOperationIndex) {
        NSOperation <INSChainableOperationProtocol> *nextOperation = self.internalQueue.operations[nextOperationIndex];
        if ([nextOperation conformsToProtocol:@protocol(INSChainableOperationProtocol)]) {
            
            id additionalObject = nil;
            if ([operation conformsToProtocol:@protocol(INSChainableOperationProtocol)] && [operation respondsToSelector:@selector(additionalDataToPassForChainedOperation)]) {
                additionalObject = [(id <INSChainableOperationProtocol>)operation additionalDataToPassForChainedOperation];
            }
            
            if ([nextOperation respondsToSelector:@selector(chainedOperation:didFinishWithErrors:passingAdditionalData:)]) {
                [nextOperation chainedOperation:operation didFinishWithErrors:errors passingAdditionalData:additionalObject];
            }
        }
    };
}

#pragma mark - INSOperationQueueDelegate
- (void)operationQueue:(INSOperationQueue *)operationQueue willAddOperation:(NSOperation *)operation {
    NSAssert(!self.finishingOperation.finished && !self.finishingOperation.executing, @"cannot add new operations to a group after the group has completed");
    
    /*
     Some operation in this group has produced a new operation to execute.
     We want to allow that operation to execute before the group completes,
     so we'll make the finishing operation dependent on this newly-produced operation.
     */
    if (operation != self.finishingOperation) {
        [self.finishingOperation addDependency:operation];
    }
}
- (void)operationQueue:(INSOperationQueue *)operationQueue operationDidFinish:(NSOperation *)operation withErrors:(NSArray <NSError *>*)errors {
    [self.aggregatedErrors addObjectsFromArray:errors];

    if (operation == self.finishingOperation) {
        [self finishWithErrors:[self.aggregatedErrors copy]];
        if (self.internalQueue.operations.count > 0) {
            [self.internalQueue cancelAllOperations];
        }
        
    } else if (self.finishIfProducedAnyError && self.aggregatedErrors.count) {
        self.internalQueue.suspended = YES;
        [self.internalQueue cancelAllOperations];
        self.internalQueue.suspended = NO;
        [self finishWithErrors:[self.aggregatedErrors copy]];
    } else {
        [self operationDidFinish:operation withErrors:errors];
    }
}

@end
