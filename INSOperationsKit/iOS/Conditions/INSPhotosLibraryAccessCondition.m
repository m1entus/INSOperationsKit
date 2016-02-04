//
//  INSPhotosLibraryAccessCondition.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 06.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#if TARGET_OS_IPHONE

#import "INSPhotosLibraryAccessCondition.h"
#import "INSPhotosLibraryAccessOperation.h"
#import "NSError+INSOperationKit.h"
#import "INSOperationConditionResult.h"
@import Photos;

@implementation INSPhotosLibraryAccessCondition

#pragma mark - Subclass

- (NSString *)name {
    return NSStringFromClass([INSPhotosLibraryAccessCondition class]);
}

- (BOOL)isMutuallyExclusive {
    return NO;
}

- (NSOperation *)dependencyForOperation:(INSOperation *)operation {
    return [[INSPhotosLibraryAccessOperation alloc] init];
}

- (void)evaluateForOperation:(INSOperation *)operation completion:(void (^)(INSOperationConditionResult *))completion {
    
    switch ([PHPhotoLibrary authorizationStatus]) {
        case PHAuthorizationStatusAuthorized:{
            completion([INSOperationConditionResult satisfiedResult]);
        } break;
            
        default:{
            NSError *error = [NSError ins_operationErrorWithCode:INSOperationErrorConditionFailed
                                                        userInfo:@{ INSOperationErrorConditionKey : NSStringFromClass([self class])
                                                                    }];
            completion([INSOperationConditionResult failedResultWithError:error]);
        } break;
    }
}

@end

#endif
