//
//  INSCoreDataParsable.h
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 07.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

@class NSManagedObjectContext;

@protocol INSCoreDataParsable
+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context;
- (void)importValuesFromDictionary:(NSDictionary *)dictionary;
@end
