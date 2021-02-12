//
//  INSExclusivityController.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSExclusivityController.h"
#import "INSOperation.h"

@interface INSExclusivityController ()
@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableArray *> *operations;
@end

@implementation INSExclusivityController

+ (instancetype)sharedInstance {

    static dispatch_once_t oncePredicate;
    static id _sharedInstance = nil;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}
- (instancetype)init {
    if (self = [super init]) {
        _serialQueue = dispatch_queue_create("io.inspace.insoperationkit.exclusivitycontroller", DISPATCH_QUEUE_SERIAL);
        _operations = [NSMutableDictionary dictionary];
    }
    return self;
}

- (nonnull NSArray <INSOperation *>*)operationsForCategory:(NSString *)category {
    return [self.operations[category] copy];
}

/// Registers an operation as being mutually exclusive
- (void)addOperation:(INSOperation *)operation categories:(NSArray <NSString *> *)categories {
    /*
     This needs to be a synchronous operation.
     If this were async, then we might not get around to adding dependencies
     until after the operation had already begun, which would be incorrect.
     */
    dispatch_sync(_serialQueue, ^{
        for (NSString *category in categories) {
            [self noqueue_addOperation:operation category:category];
        }
    });
}

/// Unregisters an operation from being mutually exclusive.
- (void)removeOperation:(INSOperation *)operation categories:(NSArray <NSString *> *)categories {
    dispatch_sync(_serialQueue, ^{
        for (NSString *category in categories) {
            [self noqueue_removeOperation:operation category:category];
        }
    });
}

#pragma mark - Operation Management
- (void)noqueue_addOperation:(INSOperation *)operation category:(NSString *)category {
    NSMutableArray *operationsWithThisCategory = _operations[category] ?: @[].mutableCopy;
    
    INSOperation *last = operationsWithThisCategory.lastObject;
    
    NSAssert(operation != last, @"You are trying to add operation dependency of itself which is really bad.");
    if (operation == last) {
        return;
    }
    
    if (last) {
        [operation addDependency:last];
    }

    [operationsWithThisCategory addObject:operation];

    self.operations[category] = operationsWithThisCategory;
}

- (void)noqueue_removeOperation:(INSOperation *)operation category:(NSString *)category {
    NSMutableArray *matchingOperations = self.operations[category];
    if (matchingOperations) {
        [matchingOperations removeObject:operation];
        self.operations[category] = matchingOperations;
    }
}

@end
