//
//  INSMutuallyExclusiveCondition.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 04.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSMutuallyExclusiveCondition.h"
#import "INSOperationConditionResult.h"

#if TARGET_OS_IPHONE
@import UIKit;
#endif

@interface INSMutuallyExclusiveCondition ()
@property (nonatomic, copy) NSString *conditionName;
@property (nonatomic, assign) Class klass;
@end

@implementation INSMutuallyExclusiveCondition

+ (instancetype)mutualExclusiveForClass:(Class)klass {
    INSMutuallyExclusiveCondition *mutex = [[INSMutuallyExclusiveCondition alloc] init];
    mutex.conditionName = NSStringFromClass(klass);
    return mutex;
}

+ (instancetype)mutualExclusiveForName:(NSString *)name {
    INSMutuallyExclusiveCondition *mutex = [[INSMutuallyExclusiveCondition alloc] init];
    mutex.conditionName = name;
    return mutex;
}

#if TARGET_OS_IPHONE
+ (instancetype)alertMutallyExclusive {
    return [self mutualExclusiveForClass:[UIAlertController class]];
}
+ (instancetype)viewControllerMutallyExclusive {
    return [self mutualExclusiveForClass:[UIViewController class]];
}
#endif

#pragma mark - Subclass

- (NSString *)name {
    return [NSString stringWithFormat:@"INSMutuallyExclusiveCondition<%@>", self.conditionName];
}

- (BOOL)isMutuallyExclusive {
    return YES;
}

- (NSOperation *)dependencyForOperation:(INSOperation *)operation {
    return nil;
}

- (void)evaluateForOperation:(INSOperation *)operation completion:(void (^)(INSOperationConditionResult *))completion {
    completion([INSOperationConditionResult satisfiedResult]);
}

@end

@implementation INSMutallyExclusiveCondition
@end
