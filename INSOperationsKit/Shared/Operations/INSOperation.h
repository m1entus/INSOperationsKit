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
#import "INSChainableOperationProtocol.h"

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

@interface INSOperation : NSOperation <INSChainableOperationProtocol>
@property (readonly, getter=isCancelled) BOOL cancelled;
@property (nonatomic, assign) BOOL userInitiated;
@property (nonatomic, readonly) INSOperationState state;

@property (nonatomic, weak, readonly, nullable) INSOperationQueue *enqueuedOperationQueue;

@property (nonatomic, strong, nonnull, readonly) NSArray <NSObject <INSOperationConditionProtocol> *> *conditions;
@property (nonatomic, strong, nonnull, readonly) NSArray <NSObject <INSOperationObserverProtocol> *> *observers;
@property (nonatomic, strong, nonnull, readonly) NSArray <NSError *> *internalErrors;

@property (nonatomic, strong, nonnull, readonly) NSHashTable <INSOperation <INSChainableOperationProtocol> *> *chainedOperations;

- (void)addObserver:(nonnull NSObject<INSOperationObserverProtocol> *)observer;
- (void)addCondition:(nonnull NSObject<INSOperationConditionProtocol> *)condition;

- (void)willEnqueueInOperationQueue:(nonnull INSOperationQueue *)operationQueue NS_REQUIRES_SUPER;

- (void)runInGlobalQueue;

- (void)finish;
- (void)finishWithErrors:(nullable NSArray <NSError *> *)errors NS_REQUIRES_SUPER;
- (void)finishWithError:(nullable NSError *)error;

- (void)finishedWithErrors:(nonnull NSArray <NSError *> *)errors;

- (void)cancelWithError:(nullable NSError *)error;
- (void)cancelWithErrors:(nullable NSArray <NSError *> *)errors;

- (void)execute;
- (void)produceOperation:(nonnull NSOperation *)operation NS_REQUIRES_SUPER;

- (nonnull INSOperation <INSChainableOperationProtocol> *)chainWithOperation:(nonnull INSOperation <INSChainableOperationProtocol> *)operation;
+ (void)chainOperations:(nonnull NSArray <INSOperation <INSChainableOperationProtocol> *>*)operations;

@end
