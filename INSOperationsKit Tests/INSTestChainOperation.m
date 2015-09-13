//
//  INSTestChainOperation.m
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 10.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import "INSTestChainOperation.h"

@implementation INSTestChainOperation

+ (instancetype)operationWithAdditionalDataToPass:(INSTestChainOperationAdditionalParameterBlock)additionalDataToPass operationFinishBlock:(INSTestChainOperationFinishBlock)finishBlock {
    INSTestChainOperation *op = [[INSTestChainOperation alloc] init];
    op.additionalDataToPassBlock = additionalDataToPass;
    op.chainedOperationFinishedBlock = finishBlock;
    return op;
}

- (void)chainedOperation:(NSOperation *)operation didFinishWithErrors:(NSArray <NSError *>*)errors passingAdditionalData:(id)data {
    if (self.chainedOperationFinishedBlock) {
        self.chainedOperationFinishedBlock(operation,errors,data);
    }
}
- (id)additionalDataToPassForChainedOperation {
    if (self.additionalDataToPassBlock) {
        return self.additionalDataToPassBlock();
    }
    return nil;
}

@end
