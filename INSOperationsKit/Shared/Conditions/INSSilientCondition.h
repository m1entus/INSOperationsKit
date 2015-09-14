//
//  INSSilientCondition.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 06.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INSOperationConditionProtocol.h"

/**
 A simple condition that causes another condition to not enqueue its dependency.
 This is useful (for example) when you want to verify that you have access to
 the user's location, but you do not want to prompt them for permission if you
 do not already have it.
 */
@interface INSSilientCondition : NSObject <INSOperationConditionProtocol>
@property (nonatomic, strong, readonly) NSObject <INSOperationConditionProtocol> *condition;

+ (instancetype)silientConditionForCondition:(NSObject <INSOperationConditionProtocol> *)condition;
- (instancetype)initWithCondition:(NSObject <INSOperationConditionProtocol> *)condition;
@end
