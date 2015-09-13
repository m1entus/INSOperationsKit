//
//  SNRFetchedResultsController.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-07-11.
//  Copyright 2011 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//! Project version number for SNRFetchedResultsController.
FOUNDATION_EXPORT double SNRFetchedResultsControllerVersionNumber;

//! Project version string for SNRFetchedResultsController.
FOUNDATION_EXPORT const unsigned char SNRFetchedResultsControllerVersionString[];

enum {
    SNRFetchedResultsChangeInsert = 1,
    SNRFetchedResultsChangeDelete = 2,
    SNRFetchedResultsChangeMove = 3,
    SNRFetchedResultsChangeUpdate = 4
};
typedef NSUInteger SNRFetchedResultsChangeType;

@protocol SNRFetchedResultsControllerDelegate;
@interface SNRFetchedResultsController : NSObject
@property (nonatomic, assign) id<SNRFetchedResultsControllerDelegate> delegate;
/** Objects fetched from the managed object context. -performFetch: must be called before accessing fetchedObjects, otherwise a nil array will be returned */
@property (nonatomic, retain, readonly) NSArray *fetchedObjects;
/** Managed object context and fetch request used to execute the fetch */
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSFetchRequest *fetchRequest;
/**
 Creates a new SNRFetchedResultsController object with the specified managed object context and fetch request
 @param context The managed object context
 @param request The fetch request
 */
- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context fetchRequest:(NSFetchRequest*)request;
/**
 Performs a fetch to populate the fetchedObjects array. Will immediately return NO if there is no fetchRequest
 @param error A pointer to an NSError object that can be used to retrieve more detailed error information in the case of a failure
 @return A BOOL indicating whether the fetch was successful
 */
- (BOOL)performFetch:(NSError**)error;

/** These are just a few wrapper methods to allow easy access to the fetchedObjects array */
- (id)objectAtIndex:(NSUInteger)index;
- (NSArray*)objectsAtIndexes:(NSIndexSet*)indexes;
- (NSUInteger)indexOfObject:(id)object;
- (NSUInteger)count;
@end

@protocol SNRFetchedResultsControllerDelegate <NSObject>
@optional
/**
 Called right before the controller is about to make one or more changes to the content array
 @param controller The fetched results controller
 */
- (void)controllerWillChangeContent:(SNRFetchedResultsController*)controller;
/**
 Called right after the controller has made one or more changes to the content array
 @param controller The fetched results controller
 */
- (void)controllerDidChangeContent:(SNRFetchedResultsController*)controller;
/**
 Called for each change that is made to the content array. This method will be called multiple times throughout the change processing.
 @param controller The fetched results controller
 @param anObject The object that was updated, deleted, inserted, or moved
 @param index The original index of the object. If the object was inserted and did not exist previously, this will be NSNotFound
 @param type The type of change (update, insert, delete, or move)
 @param newIndex The new index of the object. If the object was deleted, the newIndex will be NSNotFound.
 */
- (void)controller:(SNRFetchedResultsController*)controller didChangeObject:(id)anObject atIndex:(NSUInteger)index forChangeType:(SNRFetchedResultsChangeType)type newIndex:(NSUInteger)newIndex;
@end
