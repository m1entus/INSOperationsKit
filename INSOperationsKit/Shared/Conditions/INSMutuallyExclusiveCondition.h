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
@interface INSMutuallyExclusiveCondition: NSObject <INSOperationConditionProtocol>
@property (nonatomic, copy, readonly, nonnull) NSString *name;
@property (nonatomic, assign, nullable, readonly) Class klass;

+ (nonnull instancetype)mutualExclusiveForClass:(nonnull Class)klass;
+ (nonnull instancetype)mutualExclusiveForName:(nonnull NSString *)name;

#if TARGET_OS_IPHONE
+ (nonnull instancetype)alertMutallyExclusive;
+ (nonnull instancetype)viewControllerMutallyExclusive;
#endif
@end

__deprecated_msg("INSMutallyExclusiveCondition had a type, use INSMutuallyExclusiveCondition insted of...")
@interface INSMutallyExclusiveCondition: INSMutuallyExclusiveCondition
@end
