//
//  INSNegatedCondition.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 06.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSNegatedCondition.h"
#import "NSError+INSOperationKit.h"
#import "INSOperationConditionResult.h"

NSString *const INSNegatedConditionErrorConditionKey = @"INSNegatedConditionErrorConditionKey";

@interface INSNegatedCondition ()
@property (nonatomic, strong) NSObject <INSOperationConditionProtocol> *condition;
@end

@implementation INSNegatedCondition

+ (instancetype)negatedConditionForCondition:(NSObject <INSOperationConditionProtocol> *)condition {
    return [(INSNegatedCondition *)[[self class] alloc] initWithCondition:condition];
}

- (instancetype)initWithCondition:(NSObject <INSOperationConditionProtocol> *)condition {
    if (self = [super init]) {
        self.condition = condition;
    }
    return self;
}

#pragma mark - Subclass

- (NSString *)name {
    return [NSString stringWithFormat:@"%@<%@>", NSStringFromClass([INSNegatedCondition class]), NSStringFromClass([self.condition class])];
}

- (BOOL)isMutuallyExclusive {
    return [self.condition isMutuallyExclusive];
}

- (NSOperation *)dependencyForOperation:(INSOperation *)operation {
    return [self.condition dependencyForOperation:operation];
}

- (void)evaluateForOperation:(INSOperation *)operation completion:(void (^)(INSOperationConditionResult *))completion {
    __weak typeof(self) weakSelf = self;
    [self.condition evaluateForOperation:operation completion:^(INSOperationConditionResult *result) {
        if (result.success) {
            // If the composed condition succeeded, then this one failed.
            NSError *error = [NSError ins_operationErrorWithCode:INSOperationErrorConditionFailed
                                                        userInfo:@{ INSOperationErrorConditionKey : NSStringFromClass([weakSelf class]),
                                                                    INSNegatedConditionErrorConditionKey : NSStringFromClass([weakSelf.condition class])
                                                                    }];
            completion([INSOperationConditionResult failedResultWithError:error]);
        } else {
            // If the composed condition failed, then this one succeeded.
            completion([INSOperationConditionResult satisfiedResult]);
        }
    }];
}

@end
