//
//  INSOperationTestCondition.m
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 04.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSOperationTestCondition.h"

@implementation INSOperationTestCondition

- (instancetype)initWithConditionBlock:(INSOperationTestConditionBlock)block {
    if (self = [super init]) {
        self.block = block;
    }
    return self;
}

#pragma mark - Subclass

- (NSString *)name {
    return @"TestCondition";
}

- (BOOL)isMutuallyExclusive {
    return NO;
}

- (NSOperation *)dependencyForOperation:(INSOperation *)operation {
    return self.dependencyOperation;
}

- (void)evaluateForOperation:(INSOperation *)operation completion:(void (^)(INSOperationConditionResult *))completion {
    if (self.block()) {
        completion([INSOperationConditionResult satisfiedResult]);
    } else {
        completion([INSOperationConditionResult failedResultWithError:[NSError ins_operationErrorWithCode:INSOperationErrorConditionFailed userInfo:@{@"failed":@YES}]]);
    }
    
}

@end
