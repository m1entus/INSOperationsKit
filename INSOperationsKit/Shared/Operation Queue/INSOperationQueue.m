//
//  INSOperationQueue.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSOperationQueue.h"
#import "INSOperation.h"
#import "NSOperation+INSOperationKit.h"
#import "INSBlockObserver.h"
#import "INSExclusivityController.h"

@implementation INSOperationQueue

+ (INSOperationQueue *)globalQueue {
    static INSOperationQueue *instanceOfGlobalQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceOfGlobalQueue = [[INSOperationQueue alloc] init];
    });
    return instanceOfGlobalQueue;
}

- (void)addOperation:(NSOperation *)operationToAdd {
    if ([operationToAdd isKindOfClass:[INSOperation class]]) {
        INSOperation *operation = (INSOperation *)operationToAdd;
        
        __weak typeof(self) weakSelf = self;
        // Set up a `BlockObserver` to invoke the `OperationQueueDelegate` method.
        INSBlockObserver *delegate = [[INSBlockObserver alloc]
                                       initWithStartHandler:nil
                                       produceHandler:^(INSOperation *operation, NSOperation *producedOperation) {
                                           [weakSelf addOperation:producedOperation]; }
                                       finishHandler:^(INSOperation *operation, NSArray *errors) {
                                           if ([weakSelf.delegate respondsToSelector:@selector(operationQueue:operationDidFinish:withErrors:)]) {
                                               [weakSelf.delegate operationQueue:weakSelf operationDidFinish:operation withErrors:errors];
                                           }
                                       }];
        
        [operation addObserver:delegate];
        
        // Extract any dependencies needed by this operation.
        NSMutableArray *dependencies = [NSMutableArray arrayWithCapacity:operation.conditions.count];
        [operation.conditions enumerateObjectsUsingBlock:^(NSObject <INSOperationConditionProtocol> *condition, NSUInteger idx, BOOL *stop) {
             NSOperation *dependency = [condition dependencyForOperation:operation];
             if (dependency){
                 [dependencies addObject:dependency];
             }
         }];
        
        [dependencies enumerateObjectsUsingBlock:^(NSOperation *dependency, NSUInteger idx, BOOL *stop) {
             [operation addDependency:dependency];
             [self addOperation:dependency];
         }];
        
        /*
         With condition dependencies added, we can now see if this needs
         dependencies to enforce mutual exclusivity.
         */
        
        NSMutableArray *concurrencyCategories = [NSMutableArray array];
        
        [operation.conditions enumerateObjectsUsingBlock:^(NSObject <INSOperationConditionProtocol> *condition, NSUInteger idx, BOOL *stop){
            if ([condition isMutuallyExclusive]){
                [concurrencyCategories addObject:condition.name];
            }
        }];
        
        if (concurrencyCategories.count) {
            // Set up the mutual exclusivity dependencies.
            INSExclusivityController *exclusivityController = [INSExclusivityController sharedInstance];
            
            [exclusivityController addOperation:operation categories:concurrencyCategories];
            
            __weak typeof(exclusivityController) weakExclusivityController = exclusivityController;
            INSBlockObserver *observer = [[INSBlockObserver alloc]
                                      initWithStartHandler:nil
                                      produceHandler:nil
                                      finishHandler:^(INSOperation *operation, NSArray *error) {
                                          [weakExclusivityController removeOperation:operation categories:concurrencyCategories];
                                      }];
            
            [operation addObserver:observer];
        }
        
        [operation willEnqueueInOperationQueue:self];
    } else {
        /*
         For regular `NSOperation`s, we'll manually call out to the queue's
         delegate we don't want to just capture "operation" because that
         would lead to the operation strongly referencing itself and that's
         the pure definition of a memory leak.
         */
        __weak typeof(self) weakSelf = self;
        __weak NSOperation * weakOperation = operationToAdd;
        [operationToAdd ins_addCompletionBlock:^(INSOperation *op){
            INSOperationQueue *operationQueue = weakSelf;
            NSOperation *operation = weakOperation;
            if (operationQueue && operation){
                if ([operationQueue.delegate respondsToSelector:@selector(operationQueue:operationDidFinish:withErrors:)]){
                    [operationQueue.delegate operationQueue:operationQueue operationDidFinish:operation withErrors:nil];
                }
            } else {
                return;
            }
        }];
    }
    if ([self.delegate respondsToSelector:@selector(operationQueue:willAddOperation:)]){
        [self.delegate operationQueue:self willAddOperation:operationToAdd];
    }
    [super addOperation:operationToAdd];
}

- (void)addOperations:(NSArray<NSOperation *> *)operations waitUntilFinished:(BOOL)wait {
    /*
     The base implementation of this method does not call `addOperation()`,
     so we'll call it ourselves.
     */
    for (NSOperation *operation in operations) {
        if ([operation isKindOfClass:[NSOperation class]]) {
            [self addOperation:operation];
        }
    }
    if (wait) {
        for (NSOperation *operation in operations) {
            if ([operation isKindOfClass:[NSOperation class]]) {
                [operation waitUntilFinished];
            }
        }
    }
}
@end
