//
//  INSLocationAccessCondition.m
//  INSOperationsKit Demo
//
//  Created by Timur Kuchkarov on 12.03.16.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import "INSLocationAccessCondition.h"
#import "INSLocationAccessOperation.h"
#import "INSMutuallyExclusiveCondition.h"
#import "INSOperationConditionResult.h"
#import "NSError+INSOperationKit.h"

@import CoreLocation;

NSString *const _Nonnull INSOperationErrorLocationServicesEnabledKey = @"CLLocationServicesEnabled";
NSString *const _Nonnull INSOperationErrorAuthorizationStatusKey = @"CLAuthorizationStatus";

/**
 A private `Operation` that will request permission to access the user's location,
 if permission has not already been granted.
 */

#pragma mark - "Private" class

@interface INSLocationPermissionOperation : INSOperation
- (instancetype)initWithUsage:(INSLocationAccessUsage)usage;
- (instancetype)init NS_UNAVAILABLE;
@end

@interface INSLocationPermissionOperation () <CLLocationManagerDelegate>
@property (nonatomic, assign) INSLocationAccessUsage usage;
@property (nonatomic, strong, nullable) CLLocationManager *locationManager;
@end

@implementation INSLocationPermissionOperation

- (instancetype)initWithUsage:(INSLocationAccessUsage)usage {
    self = [super init];
    if (self) {
        _usage = usage;
        [self addCondition:[INSMutuallyExclusiveCondition alertMutallyExclusive]];
    }
    return self;
}

- (void)execute {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

    if ((status == kCLAuthorizationStatusNotDetermined) || (status == kCLAuthorizationStatusAuthorizedWhenInUse && self.usage == INSLocationAccessUsageAlways)) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [self requestPermission];
        });
    } else {
        [self finish];
    }
}

- (void)requestPermission {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    NSString *key = @"";
    switch (self.usage) {
    case INSLocationAccessUsageWhenInUse: {
        key = @"NSLocationWhenInUseUsageDescription";
        [self.locationManager requestWhenInUseAuthorization];
        break;
    }
    case INSLocationAccessUsageAlways: {
        key = @"NSLocationAlwaysUsageDescription";
        [self.locationManager requestAlwaysAuthorization];
        break;
    }
    }

    NSAssert([[NSBundle mainBundle] objectForInfoDictionaryKey:key] != nil, @"Requesting location permission requires the %@ key in your Info.plist", key);
}

#pragma mark - CLLOcationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (manager == self.locationManager && self.executing && status != kCLAuthorizationStatusNotDetermined) {
        [self finish];
    }
}

@end

#pragma mark - Implementation

@interface INSLocationAccessCondition ()

@property (nonatomic, assign) INSLocationAccessUsage usage;

@end

@implementation INSLocationAccessCondition

- (instancetype)initWithUsage:(INSLocationAccessUsage)usage {
    self = [super init];
    if (self) {
        _usage = usage;
    }
    return self;
}

#pragma mark - INSOperationConditionProtocol
- (nonnull NSString *)name {
    return NSStringFromClass([self class]);
}

- (BOOL)isMutuallyExclusive {
    return NO;
}

- (nullable NSOperation *)dependencyForOperation:(nonnull INSOperation *)operation {
    return [[INSLocationPermissionOperation alloc] initWithUsage:self.usage];
}

- (void)evaluateForOperation:(nonnull INSOperation *)operation completion:(nonnull void (^)(INSOperationConditionResult *_Nonnull result))completion {
    BOOL enabled = [CLLocationManager locationServicesEnabled];
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

    if (enabled && ((status == kCLAuthorizationStatusAuthorizedAlways) || (self.usage == INSLocationAccessUsageWhenInUse && status == kCLAuthorizationStatusAuthorizedWhenInUse))) {
        completion([INSOperationConditionResult satisfiedResult]);
        return;
    }

    NSDictionary *userInfo = @{
        INSOperationErrorConditionKey : NSStringFromClass([self class]),
        INSOperationErrorLocationServicesEnabledKey : @(enabled),
        INSOperationErrorAuthorizationStatusKey : @(status)
    };
    NSError *error = [NSError ins_operationErrorWithCode:INSOperationErrorConditionFailed
                                                userInfo:userInfo];
    completion([INSOperationConditionResult failedResultWithError:error]);
}

@end
