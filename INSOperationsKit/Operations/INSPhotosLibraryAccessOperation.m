//
//  INSPhotosLibraryAccessOperation.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 06.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSPhotosLibraryAccessOperation.h"
#import "INSMutallyExclusiveCondition.h"
@import Photos;

@implementation INSPhotosLibraryAccessOperation

- (instancetype)init {
    if (self = [super init]) {
        [self addCondition:[INSMutallyExclusiveCondition alertMutallyExclusive]];
    }
    return self;
}

- (void)execute {
    switch ([PHPhotoLibrary authorizationStatus]) {
        case PHAuthorizationStatusNotDetermined:{
            dispatch_async(dispatch_get_main_queue(), ^{
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    [self finish];
                }];
            });
        } break;
            
        default: [self finish]; break;
    }
}

@end
