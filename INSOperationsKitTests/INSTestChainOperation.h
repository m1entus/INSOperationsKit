//
//  INSTestChainOperation.h
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 10.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import <INSOperationsKitiOS/INSOperationsKitiOS.h>

typedef id(^INSTestChainOperationAdditionalParameterBlock)();
typedef void(^INSTestChainOperationFinishBlock)(NSOperation *operation, NSArray <NSError *> *errors, id additionalDataReceived);

@interface INSTestChainOperation : INSBlockOperation <INSChainableOperationProtocol>
@property (nonatomic, copy) INSTestChainOperationAdditionalParameterBlock additionalDataToPassBlock;
@property (nonatomic, copy) INSTestChainOperationFinishBlock chainedOperationFinishedBlock;

+ (instancetype)operationWithAdditionalDataToPass:(INSTestChainOperationAdditionalParameterBlock)additionalDataToPass operationFinishBlock:(INSTestChainOperationFinishBlock)finishBlock;
@end
