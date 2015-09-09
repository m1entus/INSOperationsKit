//
//  INSEarthquake.m
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 07.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import "INSEarthquake.h"

@implementation INSEarthquake

+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
    INSEarthquake *earthquake = [NSEntityDescription insertNewObjectForEntityForName:@"INSEarthquake" inManagedObjectContext:context];
    [earthquake importValuesFromDictionary:dictionary];
    return earthquake;
}
- (void)importValuesFromDictionary:(NSDictionary *)dictionary {
    self.identifier = dictionary[@"id"];
    
    NSDictionary *properties = dictionary[@"properties"];
    self.name = properties[@"place"];
    self.webLink = properties[@"url"];
    self.magnitude = @([properties[@"mag"] doubleValue]);
    self.timestamp = [NSDate dateWithTimeIntervalSince1970:[properties[@"time"] doubleValue]];
    
    NSDictionary *geometry = dictionary[@"geometry"];
    
    NSArray *coordinates = geometry[@"coordinates"];
    if ([coordinates isKindOfClass:[NSArray class]] && coordinates.count == 3) {
        
        self.longitude = @([coordinates[0] doubleValue]);
        self.latitude = @([coordinates[1] doubleValue]);
        self.depth = @([coordinates[1] doubleValue] * 1000);
    }
}
@end
