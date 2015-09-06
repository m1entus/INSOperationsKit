//
//  INSGroupOperation.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 04.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSGroupOperation.h"
#import "INSOperationQueue.h"

@interface INSGroupOperation () <INSOperationQueueDelegate>
@property (nonatomic, strong) INSOperationQueue *internalQueue;
@property (nonatomic, copy) NSBlockOperation *finishingOperation;
@property (nonatomic, strong) NSMutableArray /*NSError*/ *aggregatedErrors;
@end

@implementation INSGroupOperation

+ (instancetype)operationWithOperations:(NSArray *)operations {
    return [[[self class] alloc] initWithOperations:operations];
}

- (instancetype)initWithOperations:(NSArray /*NSOperations*/ *)operations {
    if (self = [super init]) {
        _finishingOperation = [NSBlockOperation blockOperationWithBlock:^{}];
        _aggregatedErrors = [NSMutableArray array];
        _internalQueue = [[INSOperationQueue alloc] init];
        _internalQueue.suspended = YES;
        _internalQueue.delegate = self;

        for (NSOperation *op in operations) {
            [_internalQueue addOperation:op];
        }
    }
    return self;
}

- (void)cancel {
    [self.internalQueue cancelAllOperations];
    self.internalQueue.suspended = NO;
    [super cancel];
}
- (void)execute {
    self.internalQueue.suspended = NO;
    [self.internalQueue addOperation:self.finishingOperation];
}
- (void)addOperation:(NSOperation *)operation {
    [self.internalQueue addOperation:operation];
}

/**
 Note that some part of execution has produced an error.
 Errors aggregated through this method will be included in the final array
 of errors reported to observers and to the `finished(_:)` method.
 */
- (void)aggregateError:(NSError *)error {
    [self.aggregatedErrors addObject:error];
}

- (void)operationDidFinish:(NSOperation *)operation withErrors:(NSArray *)errors {
    // For use by subclassers.
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
- (void)operationQueue:(INSOperationQueue *)operationQueue operationDidFinish:(NSOperation *)operation withErrors:(NSArray *)errors {
    [self.aggregatedErrors addObjectsFromArray:errors];

    if (operation == self.finishingOperation) {
        self.internalQueue.suspended = YES;
        [self finishWithErrors:[self.aggregatedErrors copy]];
    } else {
        [self operationDidFinish:operation withErrors:errors];
    }
}
@end
