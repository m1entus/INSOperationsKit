//
//  INSOperationObserver.h
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

@class INSOperation;

/**
 The protocol that types may implement if they wish to be notified of significant
 operation lifecycle events.
 */
@protocol INSOperationObserverProtocol <NSObject>

/// Invoked immediately prior to the `INSOperation`'s `execute()` method.
-(void)operationDidStart:(INSOperation *)operation;

/// Invoked when `INSOperation.produceOperation(_:)` is executed.
-(void)operation:(INSOperation *)operation didProduceOperation:(NSOperation *)newOperation;

/**
 Invoked as an `INSOperation` finishes, along with any errors produced during
 execution (or readiness evaluation).
 */
-(void)operationDidFinish:(INSOperation *)operation errors:(NSArray *)errors;

@end
