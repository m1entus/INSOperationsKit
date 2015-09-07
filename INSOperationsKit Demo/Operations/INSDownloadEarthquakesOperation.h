//
//  INSDownloadOperation.h
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 07.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import <INSOperationsKit/INSOperationsKit.h>
#import <CoreData/CoreData.h>

@interface INSDownloadEarthquakesOperation : INSOperation
- (instancetype)initWithContext:(NSManagedObjectContext *)context completionHandler:(void(^)())completionHandler;
@end
