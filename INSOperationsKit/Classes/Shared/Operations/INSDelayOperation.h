//
//  INSDelayOperation.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 04.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSOperation.h"

/**
 `DelayOperation` is an `Operation` that will simply wait for a given time
 interval, or until a specific `NSDate`.
 
 It is important to note that this operation does **not** use the `sleep()`
 function, since that is inefficient and blocks the thread on which it is called.
 Instead, this operation uses `dispatch_after` to know when the appropriate amount
 of time has passed.
 
 If the interval is negative, or the `NSDate` is in the past, then this operation
 immediately finishes.
 */
@interface INSDelayOperation : INSOperation
- (nonnull instancetype)initWithDelay:(NSTimeInterval)delay;
+ (nonnull instancetype)operationWithDelay:(NSTimeInterval)delay;

- (nonnull instancetype)initWithDelayUntilDate:(nonnull NSDate *)date;
+ (nonnull instancetype)operationWithDelayUntilDate:(nonnull NSDate *)date;
@end
