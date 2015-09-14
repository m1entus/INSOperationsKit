//
//  INSMutuallyExclusiveCondition.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 04.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INSOperationConditionProtocol.h"

/// A generic condition for describing kinds of operations that may not execute concurrently.
@interface INSMutallyExclusiveCondition : NSObject <INSOperationConditionProtocol>
@property (nonatomic, assign, readonly) Class klass;

+ (instancetype)mutualExclusiveForClass:(Class)klass;

#if TARGET_OS_IPHONE
+ (instancetype)alertMutallyExclusive;
+ (instancetype)viewControllerMutallyExclusive;
#endif
@end
