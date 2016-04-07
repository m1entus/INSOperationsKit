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

typedef void(^INSReachabilityConditionCompletion)(INSOperationConditionResult *result);

@interface INSReachabilityCondition ()
@property (nonatomic, strong) NSURL *host;
@property (nonatomic, strong) INSReachabilityManager *reachabilityManager;
@property (nonatomic, copy) INSReachabilityConditionCompletion completionBlock;
@end

@implementation INSReachabilityCondition

- (void)dealloc {
    NSError *error = [NSError ins_operationErrorWithCode:INSOperationErrorConditionFailed
                                                userInfo:@{ INSOperationErrorConditionKey : NSStringFromClass([self class]) }];
    if (self.completionBlock) {
        self.completionBlock([INSOperationConditionResult failedResultWithError:error]);
    }
    
    self.completionBlock = nil;
    
    [self.reachabilityManager setReachabilityStatusChangeBlock:nil];
    [self.reachabilityManager stopMonitoring];
    self.reachabilityManager = nil;
}

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
    self.completionBlock = completion;
    __weak typeof(self) weakSelf = self;
    [self.reachabilityManager setReachabilityStatusChangeBlock:^void(INSReachabilityStatus status) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (status <= INSReachabilityStatusNotReachable) {
            NSError *error = [NSError ins_operationErrorWithCode:INSOperationErrorConditionFailed
                                                        userInfo:@{ INSOperationErrorConditionKey : NSStringFromClass([weakSelf class]) }];
            if (strongSelf.completionBlock) {
                strongSelf.completionBlock([INSOperationConditionResult failedResultWithError:error]);
            }
            
            strongSelf.completionBlock = nil;
        } else {
            if (strongSelf.completionBlock) {
                strongSelf.completionBlock([INSOperationConditionResult satisfiedResult]);
            }
            
            strongSelf.completionBlock = nil;
        }
    }];
    [self.reachabilityManager startMonitoring];
}

@end
