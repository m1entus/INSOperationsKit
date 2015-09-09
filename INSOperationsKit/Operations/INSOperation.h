//
//  INSOperation.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

@import Foundation;

#import "INSOperationObserverProtocol.h"
#import "INSOperationConditionProtocol.h"

typedef NS_ENUM(NSUInteger, INSOperationState) {
    /// The initial state of an `Operation`.
    INSOperationStateInitialized,

    /// The `Operation` is ready to begin evaluating conditions.
    INSOperationStatePending,

    /// The `Operation` is evaluating conditions.
    INSOperationStateEvaluatingConditions,

    /**
     The `Operation`'s conditions have all been satisfied, and it is ready
     to execute.
     */
    INSOperationStateReady,

    /// The `Operation` is executing.
    INSOperationStateExecuting,

    /**
     Execution of the `Operation` has finished, but it has not yet notified
     the queue of this.
     */
    INSOperationStateFinishing,

    /// The `Operation` has finished executing.
    INSOperationStateFinished
};

@class INSOperationQueue;

@interface INSOperation : NSOperation
@property (readonly, getter=isCancelled) BOOL cancelled;
@property (nonatomic, assign) BOOL userInitiated;
@property (nonatomic, readonly) INSOperationState state;

@property (nonatomic, weak, readonly) INSOperationQueue *enqueuedOperationQueue;

@property (nonatomic, strong, readonly) NSArray *conditions;
@property (nonatomic, strong, readonly) NSArray *observers;
@property (nonatomic, strong, readonly) NSArray *internalErrors;

- (void)addObserver:(NSObject<INSOperationObserverProtocol> *)observer;
- (void)addCondition:(NSObject<INSOperationConditionProtocol> *)condition;

- (void)willEnqueueInOperationQueue:(INSOperationQueue *)operationQueue;

- (void)runInGlobalQueue;

- (void)finish;
- (void)finishWithErrors:(NSArray *)errors;
- (void)finishWithError:(NSError *)error;

- (void)finishedWithErrors:(NSArray *)errors;

- (void)cancelWithError:(NSError *)error;
- (void)cancelWithErrors:(NSArray *)errors;

- (void)execute;
- (void)produceOperation:(NSOperation *)operation;
@end
