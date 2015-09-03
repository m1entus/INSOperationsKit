//
//  INSOperationQueue.h
//  INSOperationsKit Demo
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
-(void)operationQueue:(INSOperationQueue *)operationQueue willAddOperation:(NSOperation *)operation;
-(void)operationQueue:(INSOperationQueue *)operationQueue operationDidFinish:(NSOperation *)operation withErrors:(NSArray *)errors;
@end

/**
 `INSOperationQueue` is an `NSOperationQueue` subclass that implements a large
 number of "extra features" related to the `Operation` class:
 
 - Notifying a delegate of all operation completion
 - Extracting generated dependencies from operation conditions
 - Setting up dependencies to enforce mutual exclusivity
 */
@interface INSOperationQueue : NSOperationQueue
@property (nonatomic, weak) id <INSOperationQueueDelegate> delegate;
@end
