//
//  INSOperationTestCondition.h
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 04.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <INSOperationsKit/INSOperationsKit.h>

typedef BOOL(^INSOperationTestConditionBlock)();

@interface INSOperationTestCondition : NSObject <INSOperationConditionProtocol>
@property (nonatomic, copy) INSOperationTestConditionBlock block;
@property (nonatomic, strong) NSOperation *dependencyOperation;
- (instancetype)initWithConditionBlock:(INSOperationTestConditionBlock)block;
@end
