//
//  INSEarthquakeOperationsProvider.h
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 09.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INSOperationsKit.h"

@interface INSEarthquakeOperationsProvider : NSObject

+ (INSChainOperation *)getAllEarthquakesWithCompletionHandler:(void (^)(INSChainOperation *operation, NSError *error))completionHandler;

@end
