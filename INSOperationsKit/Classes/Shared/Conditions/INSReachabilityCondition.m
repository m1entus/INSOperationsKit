//
//  INSReachabilityCondition.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 04.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSReachabilityCondition.h"
#import "INSReachabilityManager.h"
#import "INSOperationConditionResult.h"
#import "NSError+INSOperationKit.h"

@interface INSReachabilityCondition ()
@property (nonatomic, strong) NSURL *host;
@end

@implementation INSReachabilityCondition

+ (instancetype)reachabilityCondition {
    return [[[self class ]alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        if (![INSReachabilityManager sharedManager].isMonitoring) {
            [[INSReachabilityManager sharedManager] startMonitoring];
        }

    }
    return self;
}

- (NSString *)name {
    return NSStringFromClass([INSReachabilityCondition class]);
}

- (BOOL)isMutuallyExclusive {
    return NO;
}

- (NSOperation *)dependencyForOperation:(INSOperation *)operation {
    return nil;
}

- (void)evaluateForOperation:(INSOperation *)operation completion:(void (^)(INSOperationConditionResult *))completion {
    if (![INSReachabilityManager sharedManager].isMonitoring) {
        [[INSReachabilityManager sharedManager] startMonitoring];
    }
    
    INSReachabilityStatus status = [INSReachabilityManager sharedManager].networkReachabilityStatus;
    
    if (status == INSReachabilityStatusUnknown) {
        [[INSReachabilityManager sharedManager] addSingleCallReachabilityStatusChangeBlock:^(INSReachabilityStatus status) {
            if (status <= INSReachabilityStatusNotReachable) {
                NSError *error = [NSError ins_operationErrorWithCode:INSOperationErrorConditionFailed
                                                            userInfo:@{ INSOperationErrorConditionKey : NSStringFromClass([self class]) }];
                if (completion) {
                    completion([INSOperationConditionResult failedResultWithError:error]);
                }
            } else {
                if (completion) {
                    completion([INSOperationConditionResult satisfiedResult]);
                }
            }
        }];
        
    } else if (status <= INSReachabilityStatusNotReachable) {
        NSError *error = [NSError ins_operationErrorWithCode:INSOperationErrorConditionFailed
                                                    userInfo:@{ INSOperationErrorConditionKey : NSStringFromClass([self class]) }];
        if (completion) {
            completion([INSOperationConditionResult failedResultWithError:error]);
        }
    } else {
        if (completion) {
            completion([INSOperationConditionResult satisfiedResult]);
        }
    }

}

@end
