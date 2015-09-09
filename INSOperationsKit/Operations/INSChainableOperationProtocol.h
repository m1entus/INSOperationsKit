//
//  INSChainableOperationProtocol.h
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 07.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

@protocol INSChainableOperationProtocol
@optional
- (void)chainedOperation:(NSOperation *)operation didFinishWithErrors:(NSArray <NSError *>*)errors passingAdditionalData:(id)data;
- (id)additionalDataToPassForChainedOperation;
@end
