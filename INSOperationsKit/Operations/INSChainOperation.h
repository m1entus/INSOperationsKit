//
//  INSChainOperation.h
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 07.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import <INSOperationsKit/INSOperationsKit.h>
#import "INSChainableOperationProtocol.h"

@interface INSChainOperation : INSOperation
@property (nonatomic, assign) BOOL finishIfProducedAnyError;
+ (instancetype)operationWithOperations:(NSArray <INSOperation <INSChainableOperationProtocol> *>*)operations;
- (instancetype)initWithOperations:(NSArray <INSOperation <INSChainableOperationProtocol> *>*)operations;
- (void)addOperation:(NSOperation *)operation;
@end
