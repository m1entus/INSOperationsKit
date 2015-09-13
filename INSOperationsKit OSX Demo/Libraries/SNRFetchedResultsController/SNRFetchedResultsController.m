//
//  SNRFetchedResultsController.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-07-11.
//  Copyright 2011 Indragie Karunaratne. All rights reserved.
//

#import "SNRFetchedResultsController.h"

@interface SNRFetchedResultsController ()
- (void)managedObjectContextObjectsDidChange:(NSNotification*)notification;
- (void)delegateDidChangeObject:(id)anObject atIndex:(NSUInteger)index forChangeType:(SNRFetchedResultsChangeType)type newIndex:(NSUInteger)newIndex;
- (void)delegateWillChangeContent;
- (void)delegateDidChangeContent;
@end

@interface SNRFetchedResultsUpdate : NSObject
@property (nonatomic, retain) NSManagedObject *object;
@property (nonatomic, assign) NSUInteger originalIndex;
@end

@implementation SNRFetchedResultsController {
    NSMutableArray *sFetchedObjects;
    BOOL sDidCallDelegateWillChangeContent;
    
    struct {
        BOOL delegateHasWillChangeContent;
        BOOL delegateHasDidChangeContent;
        BOOL delegateHasDidChangeObject;
    } sDelegateHas;
}
@synthesize fetchedObjects = sFetchedObjects;
@synthesize fetchRequest = sFetchRequest;
@synthesize managedObjectContext = sManagedObjectContext;
@synthesize delegate = sDelegate;

#pragma mark -
#pragma mark Initialization

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context fetchRequest:(NSFetchRequest *)request
{
    if ((self = [super init])) {
        sManagedObjectContext = context;
        sFetchRequest = request;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:sManagedObjectContext];
    }
    return self;
}

#pragma mark -
#pragma mark Fetched Objects

- (BOOL)performFetch:(NSError**)error
{
    if (!self.fetchRequest) { return NO; }
    sFetchedObjects = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:self.fetchRequest error:error]];
    return (sFetchedObjects != nil);
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [sFetchedObjects objectAtIndex:index];
}

- (NSArray*)objectsAtIndexes:(NSIndexSet*)indexes
{
    return [sFetchedObjects objectsAtIndexes:indexes];
}

- (NSUInteger)indexOfObject:(id)object
{
    return [sFetchedObjects indexOfObject:object];
}

- (NSUInteger)count
{
    return [sFetchedObjects count];
}

#pragma mark - Accessors

- (void)setDelegate:(id<SNRFetchedResultsControllerDelegate>)delegate
{
    sDelegate = delegate;
    sDelegateHas.delegateHasWillChangeContent = [sDelegate respondsToSelector:@selector(controllerWillChangeContent:)];
    sDelegateHas.delegateHasDidChangeContent = [sDelegate respondsToSelector:@selector(controllerDidChangeContent:)];
    sDelegateHas.delegateHasDidChangeObject = [sDelegate respondsToSelector:@selector(controller:didChangeObject:atIndex:forChangeType:newIndex:)];
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Private

// Gathered most of the details for this method based on information from Apple docs on NSFetchedResultsController 
// <http://developer.apple.com/library/ios/DOCUMENTATION/CoreData/Reference/NSFetchedResultsController_Class/Reference/Reference.html#//apple_ref/doc/c_ref/NSFetchedResultsController> 
// and NSFetchedResultsControllerDelegate 
// <http://developer.apple.com/library/ios/DOCUMENTATION/CoreData/Reference/NSFetchedResultsControllerDelegate_Protocol/Reference/Reference.html#//apple_ref/occ/intf/NSFetchedResultsControllerDelegate>

- (void)managedObjectContextObjectsDidChange:(NSNotification*)notification
{
    if (!self.fetchRequest) { return; }
    NSDictionary *userInfo = [notification userInfo];
    NSPredicate *predicate = [self.fetchRequest predicate];
    NSEntityDescription *entity = [self.fetchRequest entity];
    NSArray *sortDescriptors = [self.fetchRequest sortDescriptors];
    NSArray *sortKeys = [sortDescriptors valueForKey:@"key"];
    // Are arrays faster to enumerate than sets?
    NSArray *insertedObjects = [[userInfo valueForKey:NSInsertedObjectsKey] allObjects];
    NSArray *updatedObjects = [[userInfo valueForKey:NSUpdatedObjectsKey] allObjects];
    NSArray *deletedObjects = [[userInfo valueForKey:NSDeletedObjectsKey] allObjects];
    NSMutableArray *inserted = [NSMutableArray array]; // objects to insert and sort at the end
    NSMutableArray *updated = [NSMutableArray array]; // updated objects that change the sorting of the array. Updated objects that do not affect sorting will be updated immediately instead of being put in this array
    sDidCallDelegateWillChangeContent = NO;
    for (NSManagedObject *object in deletedObjects) {
        // Don't care about objects of a different entity
        if (![[object entity] isKindOfEntity:entity]) { continue; }
        // Check to see if the content array contains the deleted object
        NSUInteger index = [sFetchedObjects indexOfObject:object];
        if (index == NSNotFound) { continue; }
        [sFetchedObjects removeObjectAtIndex:index];
        [self delegateDidChangeObject:object atIndex:index forChangeType:SNRFetchedResultsChangeDelete newIndex:NSNotFound];
    }
    for (NSManagedObject *object in updatedObjects) {
        // Ignore objects of a different entity
        if (![[object entity] isKindOfEntity:entity]) { continue; }
        // Check to see if the predicate evaluates regardless of whether the object exists in the content array or not
        // because changes to the attributes of the object can result in it either being removed or added to the 
        // content array depending on whether it affects the evaluation of the predicate
        BOOL predicateEvaluates = (predicate != nil) ? [predicate evaluateWithObject:object] : YES;
        NSUInteger objectIndex = [self.fetchedObjects indexOfObject:object];
        BOOL containsObject = (objectIndex != NSNotFound);
        // If the content array already contains the object but the update resulted in the predicate
        // no longer evaluating to TRUE, then it needs to be removed
        if (containsObject && !predicateEvaluates) {
            [sFetchedObjects removeObjectAtIndex:objectIndex];
            [self delegateDidChangeObject:object atIndex:objectIndex forChangeType:SNRFetchedResultsChangeDelete newIndex:NSNotFound];
        // If the content array does not contain the object but the object's update resulted in the predicate now 
        // evaluating to TRUE, then it needs to be inserted
        } else if (!containsObject && predicateEvaluates) {
            [inserted addObject:object];
        } else if (containsObject) {
            // Check if the object's updated keys are in the sort keys
            // This means that the sorting would have to be updated 
            BOOL sortingChanged = NO;
            if ([sortKeys count]) {
                NSArray *keys = [[object changedValues] allKeys];
                for (NSString *key in sortKeys) {
                    if ([keys containsObject:key]) {
                        sortingChanged = YES;
                        break;
                    }
                }
            }
            if (sortingChanged) {
                // Create a wrapper object that keeps track of the original index for later
                SNRFetchedResultsUpdate *update = [SNRFetchedResultsUpdate new];
                update.originalIndex = objectIndex;
                update.object = object;
                [updated addObject:update];
            } else {
                // If there's no change in sorting then just update the object as-is
                [self delegateDidChangeObject:object atIndex:objectIndex forChangeType:SNRFetchedResultsChangeUpdate newIndex:objectIndex];
            }
        }
    }
    // If there were updated objects that changed the sorting then resort and notify the delegate of changes
    if ([updated count] && [sortDescriptors count]) {
        [sFetchedObjects sortUsingDescriptors:sortDescriptors];
        for (SNRFetchedResultsUpdate *update in updated) {
            // Find out then new index of the object in the content array
            NSUInteger newIndex = [sFetchedObjects indexOfObject:update.object];
            [self delegateDidChangeObject:update.object atIndex:update.originalIndex forChangeType:SNRFetchedResultsChangeMove newIndex:newIndex];
        }
    }
    for (NSManagedObject *object in insertedObjects) {
        // Objects of a different entity or objects that don't evaluate to the predicate are ignored
        if (![[object entity] isKindOfEntity:entity] || (predicate && ![predicate evaluateWithObject:object])) {
            continue;
        }
        [inserted addObject:object];
    }
    // If there were inserted objects then insert them into the content array and resort
    NSUInteger insertedCount = [inserted count];
    if (insertedCount) {
        // Dump the inserted objects into the content array
        [sFetchedObjects addObjectsFromArray:inserted];
        // If there are sort descriptors, then resort the array
        if ([sortDescriptors count]) {
            [sFetchedObjects sortUsingDescriptors:sortDescriptors];
            // Enumerate through each of the inserted objects and notify the delegate of their new position
            [sFetchedObjects enumerateObjectsUsingBlock:^(NSManagedObject *object, NSUInteger idx, BOOL *stop) {
                if (![inserted containsObject:object]) {
                    return;
                }

                [self delegateDidChangeObject:object atIndex:NSNotFound forChangeType:SNRFetchedResultsChangeInsert newIndex:idx];
            }];
            // If there are no sort descriptors, then the inserted objects will just be added to the end of the array
            // so we don't need to figure out what indexes they were inserted in
        } else {
            NSUInteger objectsCount = [sFetchedObjects count];
            for (NSInteger i = (objectsCount - insertedCount); i < objectsCount; i++) {
                [self delegateDidChangeObject:[sFetchedObjects objectAtIndex:0] atIndex:NSNotFound forChangeType:SNRFetchedResultsChangeInsert newIndex:i];
            }
        }
    }
    // if delegateWillChangeContent: was called then delegateDidChangeContent: must also be called
    if (sDidCallDelegateWillChangeContent) {
        [self delegateDidChangeContent];
    }
}

- (void)delegateWillChangeContent
{
    if (sDelegateHas.delegateHasWillChangeContent) {
        [self.delegate controllerWillChangeContent:self];
    }
}

- (void)delegateDidChangeContent
{
    if (sDelegateHas.delegateHasDidChangeContent) {
        [self.delegate controllerDidChangeContent:self];
    }
}

- (void)delegateDidChangeObject:(id)anObject atIndex:(NSUInteger)index forChangeType:(SNRFetchedResultsChangeType)type newIndex:(NSUInteger)newIndex
{
   // NSLog(@"Changing object: %@\nAt index: %lu\nChange type: %d\nNew index: %lu", anObject, index, (int)type, newIndex);
    if (!sDidCallDelegateWillChangeContent) {
        [self delegateWillChangeContent];
        sDidCallDelegateWillChangeContent = YES;
    }
    if (sDelegateHas.delegateHasDidChangeObject) {
        [self.delegate controller:self didChangeObject:anObject atIndex:index forChangeType:type newIndex:newIndex];
    }
}
@end

@implementation SNRFetchedResultsUpdate
@synthesize object = sObject;
@synthesize originalIndex = sOriginalIndex;
@end