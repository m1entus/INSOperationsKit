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

/// Invoked before operation is enqueued in queue
- (void)operationWillStart:(INSOperation *)operation inOperationQueue:(INSOperationQueue *)operationQueue;

/// Invoked immediately prior to the `INSOperation`'s `execute()` method.
- (void)operationDidStart:(INSOperation *)operation;

/// Invoked when `INSOperation.produceOperation(_:)` is executed.
- (void)operation:(INSOperation *)operation didProduceOperation:(NSOperation *)newOperation;

/**
 Invoked as an `INSOperation` finishes, along with any errors produced during
 execution (or readiness evaluation).
 */
- (void)operationDidFinish:(INSOperation *)operation errors:(NSArray <NSError *> *)errors;

@end
