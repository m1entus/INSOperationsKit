//
//  INSNoCancelledDependenciesCondition.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 06.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSNoCancelledDependenciesCondition.h"
#import "INSOperation.h"
#import "INSOperationConditionResult.h"
#import "NSError+INSOperationKit.h"

NSString *const INSNoCancelledDependenciesConditionErrorDependenciesKey = @"INSNoCancelledDependenciesConditionErrorDependenciesKey";

@implementation INSNoCancelledDependenciesCondition

#pragma mark - Subclass

- (NSString *)name {
    return NSStringFromClass([INSNoCancelledDependenciesCondition class]);
}

- (BOOL)isMutuallyExclusive {
    return NO;
}

- (NSOperation *)dependencyForOperation:(INSOperation *)operation {
    return nil;
}

- (void)evaluateForOperation:(INSOperation *)operation completion:(void (^)(INSOperationConditionResult *))completion {
    
    NSMutableArray *cancelledDependencies = [NSMutableArray arrayWithCapacity:operation.dependencies.count];
    
    [operation.dependencies enumerateObjectsUsingBlock:^(INSOperation *obj, NSUInteger idx, BOOL *stop) {
        if (obj.isCancelled) {
            [cancelledDependencies addObject:obj];
        }
    }];
    
    if (cancelledDependencies.count) {
        NSError *error = [NSError ins_operationErrorWithCode:INSOperationErrorConditionFailed
                                                    userInfo:@{ INSOperationErrorConditionKey : NSStringFromClass([self class]),
                                                                INSNoCancelledDependenciesConditionErrorDependenciesKey : cancelledDependencies
                                                                }];
        completion([INSOperationConditionResult failedResultWithError:error]);
        
    } else {
        completion([INSOperationConditionResult satisfiedResult]);
    }
}

@end
