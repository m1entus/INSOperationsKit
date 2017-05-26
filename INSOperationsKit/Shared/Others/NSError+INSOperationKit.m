//
//  NSError+INSOperationKit.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "NSError+INSOperationKit.h"
#import "INSReachabilityCondition.h"

NSString *const INSOperationErrorDomain = @"INSOperationErrorDomain";

NSString *const INSOperationErrorConditionKey = @"INSOperationErrorConditionKey";

@implementation NSError (INSOperationKit)

+ (instancetype)ins_operationErrorWithCode:(NSUInteger)code {
    return [self ins_operationErrorWithCode:code userInfo:nil];
}
+ (instancetype)ins_operationErrorWithCode:(NSUInteger)code userInfo:(NSDictionary *)info {
    return [NSError errorWithDomain:INSOperationErrorDomain code:code userInfo:info];
}

- (BOOL)ins_isReachabilityConditionError {
    if ([self.domain isEqualToString:INSOperationErrorDomain] &&
        [self.userInfo[INSOperationErrorConditionKey] isEqualToString:NSStringFromClass([INSReachabilityCondition class])]) {
        return YES;
    }
    return NO;
}

@end
