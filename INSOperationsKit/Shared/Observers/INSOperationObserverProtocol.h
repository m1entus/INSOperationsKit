//
//  INSOperationObserver.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

@class INSOperation;
@class INSOperationQueue;

/**
 The protocol that types may implement if they wish to be notified of significant
 operation lifecycle events.
 */
@protocol INSOperationObserverProtocol <NSObject>

@optional

/// Invoked before operation is enqueued in queue
- (void)operationWillStart:(nonnull INSOperation *)operation inOperationQueue:(nonnull INSOperationQueue *)operationQueue;

/// Invoked immediately prior to the `INSOperation`'s `execute()` method.
- (void)operationDidStart:(nonnull INSOperation *)operation;

/// Invoked immediately prior to the `INSOperation`'s `execute()` method.
- (void)operationDidStartExecuting:(nonnull INSOperation *)operation;

/// Invoked when `INSOperation.produceOperation(_:)` is executed.
- (void)operation:(nonnull INSOperation *)operation didProduceOperation:(nonnull NSOperation *)newOperation;

/**
 Invoked as an `INSOperation` finishes, along with any errors produced during
 execution (or readiness evaluation).
 */
- (void)operationDidFinish:(nonnull INSOperation *)operation errors:(nullable NSArray <NSError *> *)errors;

@end
