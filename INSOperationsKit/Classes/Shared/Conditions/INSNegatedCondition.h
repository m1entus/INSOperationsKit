//
//  INSNegatedCondition.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 06.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INSOperationConditionProtocol.h"

extern NSString *const _Nonnull INSNegatedConditionErrorConditionKey;

/**
 A simple condition that negates the evaluation of another condition.
 This is useful (for example) if you want to only execute an operation if the
 network is NOT reachable.
 */
@interface INSNegatedCondition : NSObject <INSOperationConditionProtocol>
@property (nonatomic, strong, nonnull, readonly) NSObject <INSOperationConditionProtocol> *condition;

+ (nonnull instancetype)negatedConditionForCondition:(nonnull NSObject <INSOperationConditionProtocol> *)condition;
- (nonnull instancetype)initWithCondition:(nonnull NSObject <INSOperationConditionProtocol> *)condition;
@end
