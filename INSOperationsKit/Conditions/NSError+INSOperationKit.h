//
//  NSError+INSOperationKit.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const INSOperationErrorDomain;
extern NSString *const INSOperationErrorConditionKey;

typedef NS_ENUM(NSUInteger, INSOperationError) {
    INSOperationErrorConditionFailed = 1,
    INSOperationErrorExecutionFailed = 2
};

@interface NSError (INSOperationKit)

+ (instancetype)ins_operationErrorWithCode:(NSUInteger)code;
+ (instancetype)ins_operationErrorWithCode:(NSUInteger)code userInfo:(NSDictionary *)info;

@end
