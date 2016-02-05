//
//  INSChainCondition.h
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 04.02.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INSOperationConditionProtocol.h"
#import "INSChainableOperationProtocol.h"

@interface INSChainCondition : NSObject <INSOperationConditionProtocol>
@property (nonatomic, strong, readonly) NSOperation <INSChainableOperationProtocol> *chainOperation;

+ (instancetype)chainConditionForOperation:(NSOperation <INSChainableOperationProtocol> *)operation;

@end
