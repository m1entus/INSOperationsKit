//
//  INSCoreDataStack.h
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 07.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface INSCoreDataStack : NSObject
@property (nonatomic, strong, readonly) NSManagedObjectContext *savingContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext *mainContext;

+ (INSCoreDataStack *)sharedInstance;

+ (NSError *)saveContext:(NSManagedObjectContext *)context;
- (NSError *)saveMainQueueContext;
- (void)saveMainQueueContextToPersistentStore;

- (NSManagedObjectContext *)createPrivateContextWithParentContext:(NSManagedObjectContext *)context;
- (NSManagedObjectContext *)createPrivateContextWithMainQueueParent;
@end
