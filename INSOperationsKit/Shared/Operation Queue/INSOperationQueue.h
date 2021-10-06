//
//  INSOperationQueue.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

@import Foundation;

@class INSOperation, INSOperationQueue;

/**
 The delegate of an `INSOperationQueue` can respond to `Operation` lifecycle
 events by implementing these methods.
 
 In general, implementing `INSOperationQueueDelegate` is not necessary; you would
 want to use an `INSOperationObserver` instead. However, there are a couple of
 situations where using `OperationQueueDelegate` can lead to simpler code.
 For example, `INSGroupOperation` is the delegate of its own internal
 `INSOperationQueue` and uses it to manage dependencies.
 */
@protocol INSOperationQueueDelegate <NSObject>
@optional
- (void)operationQueue:(nonnull INSOperationQueue *)operationQueue willAddOperation:(nonnull NSOperation *)operation;
- (void)operationQueue:(nonnull INSOperationQueue *)operationQueue operationDidFinish:(nonnull NSOperation *)operation withErrors:(nullable NSArray *)errors;
@end

/**
 `INSOperationQueue` is an `NSOperationQueue` subclass that implements a large
 number of "extra features" related to the `Operation` class:
 
 - Notifying a delegate of all operation completion
 - Extracting generated dependencies from operation conditions
 - Setting up dependencies to enforce mutual exclusivity
 */
@interface INSOperationQueue : NSOperationQueue
@property (nonatomic, weak, nullable) id <INSOperationQueueDelegate> delegate;

@property (readonly, copy) NSArray<__kindof NSOperation *> * _Nonnull operations API_DEPRECATED("access to operations is inherently a race condition, it should not be used. Use runningOperations which is thread safe.", macos(10.5, API_TO_BE_DEPRECATED), ios(2.0, API_TO_BE_DEPRECATED), watchos(2.0, API_TO_BE_DEPRECATED), tvos(9.0, API_TO_BE_DEPRECATED));

/// This is thread safe comparing to `operations` which is inherently a race condition
@property (readonly, copy) NSArray<__kindof NSOperation *> * _Nonnull runningOperations;

+ (nonnull INSOperationQueue *)globalQueue;
@end
