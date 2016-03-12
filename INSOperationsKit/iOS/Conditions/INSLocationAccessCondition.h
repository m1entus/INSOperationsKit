//
//  INSLocationAccessCondition.h
//  INSOperationsKit Demo
//
//  Created by Timur Kuchkarov on 12.03.16.
//  Copyright © 2016 Michal Zaborowski. All rights reserved.
//

#import "INSOperationConditionProtocol.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, INSLocationAccessUsage) {
    INSLocationAccessUsageWhenInUse = 0,
    INSLocationAccessUsageAlways = 1
};

NS_ASSUME_NONNULL_BEGIN

extern NSString *const INSOperationErrorLocationServicesEnabledKey;
extern NSString *const INSOperationErrorAuthorizationStatusKey;

/// A condition for verifying access to the user's location.
@interface INSLocationAccessCondition : NSObject <INSOperationConditionProtocol>
- (instancetype)initWithUsage:(INSLocationAccessUsage)usage;
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
