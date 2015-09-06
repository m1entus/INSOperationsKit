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
@property (nonatomic, strong) INSReachabilityManager *reachabilityManager;
@end

@implementation INSReachabilityCondition

+ (instancetype)reachabilityCondition {
    return [[[self class ]alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        self.reachabilityManager = [INSReachabilityManager managerForLocalAddress];
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
    
    __weak typeof(self) weakSelf = self;
    [self.reachabilityManager setReachabilityStatusChangeBlock:^void(INSReachabilityStatus status) {
        if (status <= INSReachabilityStatusNotReachable) {
            NSError *error = [NSError ins_operationErrorWithCode:INSOperationErrorConditionFailed
                                                        userInfo:@{ INSOperationErrorConditionKey : NSStringFromClass([weakSelf class]) }];
            completion([INSOperationConditionResult failedResultWithError:error]);
        } else {
            completion([INSOperationConditionResult satisfiedResult]);
        }
    }];
    [self.reachabilityManager startMonitoring];
}

@end
