//
//  INSLocationAccessOperation.m
//  INSOperationsKit Demo
//
//  Created by Timur Kuchkarov on 12.03.16.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import "INSLocationAccessOperation.h"
#import "INSMutuallyExclusiveCondition.h"
#import "INSLocationAccessCondition.h"

@interface INSLocationAccessOperation () <CLLocationManagerDelegate>

@property (nonatomic, assign) CLLocationAccuracy desiredAccuracy;
@property (nonatomic, copy) INSLocationOperationLocationHandler locationHandler;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation INSLocationAccessOperation

- (instancetype)initWithUsage:(INSLocationAccessUsage)usage accuracy:(CLLocationAccuracy)accuracy locationHandler:(INSLocationOperationLocationHandler)handler {
    self = [super init];
    if (self) {
        _desiredAccuracy = accuracy;
        _locationHandler = handler;
        [self addCondition:[[INSLocationAccessCondition alloc] initWithUsage:usage]];
        [self addCondition:[INSMutuallyExclusiveCondition mutualExclusiveForClass:[CLLocationManager class]]];
    }
    return self;
}

- (void)execute {
    dispatch_async(dispatch_get_main_queue(), ^{
      /*
		 `CLLocationManager` needs to be created on a thread with an active
		 run loop, so for simplicity we do this on the main queue.
		 */
      self.locationManager = [[CLLocationManager alloc] init];
      self.locationManager.desiredAccuracy = self.desiredAccuracy;
      self.locationManager.delegate = self;
      [self.locationManager startUpdatingLocation];
    });
}

- (void)cancel {
    [super cancel];
    [self stopLocationUpdates];
}

- (void)stopLocationUpdates {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.locationManager stopUpdatingLocation];
        self.locationManager = nil;
    });
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *lastLocation = [locations lastObject];
    if (lastLocation.horizontalAccuracy >= 0 && lastLocation.horizontalAccuracy <= self.desiredAccuracy) {
        [self stopLocationUpdates];
        if (self.locationHandler != nil) {
            self.locationHandler(lastLocation);
        }
        [self finish];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self stopLocationUpdates];
    [self finishWithError:error];
}

@end
