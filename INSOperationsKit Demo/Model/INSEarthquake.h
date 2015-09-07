//
//  INSEarthquake.h
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 07.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "INSCoreDataParsable.h"

NS_ASSUME_NONNULL_BEGIN

@interface INSEarthquake : NSManagedObject <INSCoreDataParsable>

@end

NS_ASSUME_NONNULL_END

#import "INSEarthquake+CoreDataProperties.h"
