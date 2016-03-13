//
//  INSEarthquake.h
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 07.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@import MapKit;
#import "INSCoreDataParsable.h"

NS_ASSUME_NONNULL_BEGIN

extern NSDateFormatter *INSEarthquakeTimestampFormatter();
extern NSNumberFormatter *INSEarthquakeMagnitudeFormatter();
extern MKDistanceFormatter *INSEarthquakeDistanceFormatter();

@interface INSEarthquake : NSManagedObject <INSCoreDataParsable>
+ (NSString *)entityName;
@end

NS_ASSUME_NONNULL_END

#import "INSEarthquake+CoreDataProperties.h"
