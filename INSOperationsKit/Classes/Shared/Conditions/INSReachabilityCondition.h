//
//  INSReachabilityCondition.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 04.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INSOperationConditionProtocol.h"

/**
 This is a condition that performs a very high-level reachability check.
 It does *not* perform a long-running reachability check, nor does it respond to changes in reachability.
 Reachability is evaluated once when the operation to which this is attached is asked about its readiness.
 */
@interface INSReachabilityCondition : NSObject <INSOperationConditionProtocol>
+ (nonnull instancetype)reachabilityCondition;
@end
