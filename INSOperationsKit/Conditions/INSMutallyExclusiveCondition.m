//
//  INSMutuallyExclusiveCondition.m
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 04.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSMutallyExclusiveCondition.h"
#import "INSOperationConditionResult.h"
@import UIKit;

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

+ (instancetype)alertMutallyExclusive {
    return [self mutualExclusiveForClass:[UIAlertController class]];
}
+ (instancetype)viewControllerMutallyExclusive {
    return [self mutualExclusiveForClass:[UIViewController class]];
}

#pragma mark - Subclass

- (NSString *)name {
    return [NSString stringWithFormat:@"MutuallyExclusive<%@>", self.className];
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
