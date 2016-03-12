//
//  INSLocationAccessOperation.h
//  INSOperationsKit Demo
//
//  Created by Timur Kuchkarov on 12.03.16.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import <INSOperationsKit/INSOperationsKit.h>
#import "INSLocationAccessCondition.h"

@import CoreLocation;

typedef void(^INSLocationOperationLocationHandler)(CLLocation *location);
@interface INSLocationAccessOperation : INSOperation

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithUsage:(INSLocationAccessUsage)usage accuracy:(CLLocationAccuracy)accuracy locationHandler:(INSLocationOperationLocationHandler)handler;

@end
