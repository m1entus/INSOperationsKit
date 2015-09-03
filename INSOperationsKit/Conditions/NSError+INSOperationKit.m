//
//  NSError+INSOperationKit.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "NSError+INSOperationKit.h"

NSString *const INSOperationErrorDomain = @"INSOperationErrorDomain";

@implementation NSError (INSOperationKit)

+ (instancetype)ins_operationErrorWithCode:(NSUInteger)code {
    return [self ins_operationErrorWithCode:code userInfo:nil];
}
+ (instancetype)ins_operationErrorWithCode:(NSUInteger)code userInfo:(NSDictionary *)info {
    return [NSError errorWithDomain:INSOperationErrorDomain code:code userInfo:info];
}

@end
