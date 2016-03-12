//
//  INSEarthquake.m
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 07.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import "INSEarthquake.h"

NSDateFormatter *INSEarthquakeTimestampFormatter() {
    static NSDateFormatter *instanceOfFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceOfFormatter = [[NSDateFormatter alloc] init];
        instanceOfFormatter.dateStyle = NSDateFormatterMediumStyle;
        instanceOfFormatter.timeStyle = NSDateFormatterMediumStyle;
    });
    return instanceOfFormatter;
};

NSNumberFormatter *INSEarthquakeMagnitudeFormatter() {
    static NSNumberFormatter *instanceOfFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceOfFormatter = [[NSNumberFormatter alloc] init];
        instanceOfFormatter.maximumFractionDigits = 1;
        instanceOfFormatter.minimumFractionDigits = 1;
    });
    return instanceOfFormatter;
};

MKDistanceFormatter *INSEarthquakeDistanceFormatter() {
	static MKDistanceFormatter *instanceOfFormatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instanceOfFormatter = [[MKDistanceFormatter alloc] init];
	});
	return instanceOfFormatter;
}

@implementation INSEarthquake

+ (NSString *)entityName {
    return @"INSEarthquake";
}

+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
    INSEarthquake *earthquake = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
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
