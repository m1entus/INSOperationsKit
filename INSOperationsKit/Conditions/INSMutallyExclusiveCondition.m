//
//  INSMutuallyExclusiveCondition.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 04.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSMutallyExclusiveCondition.h"
#import "INSOperationConditionResult.h"

#if TARGET_OS_IPHONE
@import UIKit;
#endif

@interface INSMutallyExclusiveCondition ()
@property (nonatomic, strong) NSString *className;
@property (nonatomic, assign) Class klass;
@end

@implementation INSMutallyExclusiveCondition

+ (instancetype)mutualExclusiveForClass:(Class)klass {
    INSMutallyExclusiveCondition *mutex = [[INSMutallyExclusiveCondition alloc] init];
    mutex.className = NSStringFromClass(klass);
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
    return [NSString stringWithFormat:@"INSMutallyExclusiveCondition<%@>", self.className];
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
