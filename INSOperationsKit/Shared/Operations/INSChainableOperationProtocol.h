//
//  INSChainableOperationProtocol.h
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 07.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

@protocol INSChainableOperationProtocol
@optional
- (void)chainedOperation:(nonnull NSOperation *)operation didFinishWithErrors:(nullable NSArray <NSError *>*)errors passingAdditionalData:(nullable id)data;
- (nullable id)additionalDataToPassForChainedOperation;
@end
