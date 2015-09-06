//
//  NSOperation+INSOperationKit.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "NSOperation+INSOperationKit.h"

@implementation NSOperation (INSOperationKit)
/**
 Add a completion block to be executed after the `NSOperation` enters the
 "finished" state.
 */
- (void)ins_addCompletionBlock:(void (^)(void))block {
    void (^existing)(void) = self.completionBlock;
    if (existing) {
        /*
         If we already have a completion block, we construct a new one by
         chaining them together.
         */
        self.completionBlock = ^{
            existing();
            block();
        };
    } else {
        self.completionBlock = block;
    }
}

/// Add multiple depdendencies to the operation.
- (void)ins_addDependencies:(NSArray /*NSOperation*/ *)dependencies {
    for (NSOperation *dependency in dependencies) {
        [self addDependency:dependency];
    }
}

@end
