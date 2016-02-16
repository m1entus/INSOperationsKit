//
//  INSExclusivityController.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@class INSOperation;

/**
 `ExclusivityController` is a singleton to keep track of all the in-flight
 `Operation` instances that have declared themselves as requiring mutual exclusivity.
 We use a singleton because mutual exclusivity must be enforced across the entire
 app, regardless of the `OperationQueue` on which an `Operation` was executed.
 */

@interface INSExclusivityController : NSObject
+ (nonnull instancetype)sharedInstance;

- (void)addOperation:(nonnull INSOperation *)operation categories:(nonnull NSArray <NSString *> *)categories;
- (void)removeOperation:(nonnull INSOperation *)operation categories:(nonnull NSArray <NSString *> *)categories;
@end
