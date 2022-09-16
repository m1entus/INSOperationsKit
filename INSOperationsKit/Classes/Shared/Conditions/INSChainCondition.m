//
//  INSChainCondition.m
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 04.02.2016.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import "INSChainCondition.h"
#import "INSOperationConditionResult.h"

@interface INSChainCondition ()
@property (nonatomic, strong) NSOperation <INSChainableOperationProtocol> *chainOperation;
@end

@implementation INSChainCondition

- (instancetype)initWithOpeartion:(NSOperation <INSChainableOperationProtocol> *)operation {
    if (self = [super init]) {
        self.chainOperation = operation;
    }
    return self;
}

+ (instancetype)chainConditionForOperation:(NSOperation <INSChainableOperationProtocol> *)operation {
    return [[[self class] alloc] initWithOpeartion:operation];
}

#pragma mark - Subclass

- (NSString *)name {
    return NSStringFromClass([INSChainCondition class]);
}

- (BOOL)isMutuallyExclusive {
    return NO;
}

- (NSOperation *)dependencyForOperation:(INSOperation *)operation {
    return self.chainOperation;
}

- (void)evaluateForOperation:(INSOperation *)operation completion:(void (^)(INSOperationConditionResult *))completion {
    completion([INSOperationConditionResult satisfiedResult]);
}

@end
