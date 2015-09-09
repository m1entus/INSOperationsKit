//
//  INSCoreDataStack.m
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 07.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import "INSCoreDataStack.h"

static NSString *INSCoreDataStackStoreFilename = @"INSOperationsKit.sqlite";

@interface INSCoreDataStack ()
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *presistentCoordinator;
@property (nonatomic, strong) NSPersistentStore *presistentStore;
@property (nonatomic, strong) NSManagedObjectContext *savingContext;
@property (nonatomic, strong) NSManagedObjectContext *mainContext;
@end

@implementation INSCoreDataStack

+ (INSCoreDataStack *)sharedInstance {
    static dispatch_once_t predicate;
    static INSCoreDataStack *instanceOfCoreDataStack = nil;
    dispatch_once(&predicate, ^{
        instanceOfCoreDataStack = [[INSCoreDataStack alloc] init];
        [instanceOfCoreDataStack setupCoreData];
    });
    return instanceOfCoreDataStack;
}

- (instancetype)init {
    if (self = [super init]) {
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
        _presistentCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
        
        _savingContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_savingContext performBlockAndWait:^{
            [_savingContext setPersistentStoreCoordinator:_presistentCoordinator];
            [_savingContext
             setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        }];
        
        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_mainContext setParentContext:_savingContext];
        [_mainContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [self listenForStoreChanges];
    }
    return self;
}

- (void)setupCoreData {
    if (_presistentStore) {
        return;
    }
    
    NSDictionary *options =
    @{
      NSMigratePersistentStoresAutomaticallyOption:@YES
      ,NSInferMappingModelAutomaticallyOption:@YES
      //,NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"} // Option to disable WAL mode
      };
    NSError *error = nil;
    _presistentStore = [_presistentCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                        configuration:nil
                                                  URL:[self storeURL]
                                              options:options
                                                error:&error];
    if (!_presistentStore) {
        NSLog(@"Failed to add store. Error: %@", error);
        abort();
    } else {
        NSLog(@"Successfully added store: %@", _presistentStore);
    }
}

- (NSManagedObjectContext *)createPrivateContextWithParentContext:(NSManagedObjectContext *)context {
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    newContext.parentContext = context;
    return newContext;
}
- (NSManagedObjectContext *)createPrivateContextWithMainQueueParent {
    return [self createPrivateContextWithParentContext:self.mainContext];
}

- (void)resetContext:(NSManagedObjectContext*)moc {
    [moc performBlockAndWait:^{
        [moc reset];
    }];
}

- (void)listenForStoreChanges {
    [[NSNotificationCenter defaultCenter] addObserver:self
           selector:@selector(storesWillChange:)
               name:NSPersistentStoreCoordinatorStoresWillChangeNotification
             object:_presistentCoordinator];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
           selector:@selector(persistentStoreDidImportUbiquitiousContentChanges:)
               name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
             object:_presistentCoordinator];
}

- (void)storesWillChange:(NSNotification *)notfication {
    [self.mainContext performBlockAndWait:^{
        [self.mainContext save:nil];
        [self resetContext:self.mainContext];
    }];
    [self.savingContext performBlockAndWait:^{
        [self.savingContext save:nil];
        [self resetContext:self.savingContext];
    }];
}

- (void)persistentStoreDidImportUbiquitiousContentChanges:(NSNotification *)notification {
    [self.mainContext performBlock:^{
        [self.mainContext mergeChangesFromContextDidSaveNotification:notification];
    }];
}

+ (NSError *)saveContext:(NSManagedObjectContext *)context {
    NSError *error = nil;
    
    if ([context hasChanges]) {
        if (![context save:&error]) {
            NSLog(@"Failed to save _context: %@ error: %@",context, error);
        }
    } else {
        NSLog(@"SKIPPED %@ save, there are no changes!",context);
    }
    return error;
}

- (NSError *)saveMainQueueContext {
    NSError *error = nil;
    
    if ([self.mainContext hasChanges]) {
        if ([self.mainContext save:&error]) {
            NSLog(@"_mainContext SAVED changes");
        } else {
            NSLog(@"Failed to save _mainContext: %@", error);
        }
    } else {
        NSLog(@"SKIPPED _mainContext save, there are no changes!");
    }
    return error;
}
- (void)saveMainQueueContextToPersistentStore {
    [self saveMainQueueContext];
    
    [self.savingContext performBlock:^{
        if ([self.savingContext hasChanges]) {
            NSError *error = nil;
            if ([self.savingContext save:&error]) {
                NSLog(@"_savingContext SAVED changes to persistent store");
            } else {
                NSLog(@"Failed to save _savingContext: %@", error);
            }
        }
    }];
}

#pragma mark - Paths

- (NSURL *)sourceStoreURL {
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[INSCoreDataStackStoreFilename stringByDeletingPathExtension]
                                                                  ofType:[INSCoreDataStackStoreFilename pathExtension]]];
}

- (NSURL *)storeURL {
    return [[self applicationStoresDirectory] URLByAppendingPathComponent:INSCoreDataStackStoreFilename];
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) lastObject];
}

- (NSURL *)applicationStoresDirectory {
    NSURL *storesDirectory =
    [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]] URLByAppendingPathComponent:@"Stores"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[storesDirectory path]]) {
        NSError *error = nil;
        if (![fileManager createDirectoryAtURL:storesDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"FAILED to create Stores directory: %@", error);
        }
    }
    return storesDirectory;
}

@end
