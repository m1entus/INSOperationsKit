//
//  INSTimeoutObserver.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 04.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INSOperationObserverProtocol.h"

/**
 `TimeoutObserver` is a way to make an `Operation` automatically time out and
 cancel after a specified time interval.
 */
@interface INSTimeoutObserver : NSObject <INSOperationObserverProtocol>
- (nonnull instancetype)initWithTimeout:(NSTimeInterval)interval;
@end
