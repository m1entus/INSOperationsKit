//
//  NSOperation+INSOperationKit.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "NSOperation+INSOperationKit.h"

@implementation NSOperation (INSOperationKit)

- (void)ins_addCompletionBlockInMainQueue:(void (^)(__kindof NSOperation *operation))block {
    if (!block) {
        return;
    }
    void (^existing)(void) = self.completionBlock;
    __weak typeof(self) weakSelf = self;
    if (existing) {
        /*
         If we already have a completion block, we construct a new one by
         chaining them together.
         */
        self.completionBlock = ^{
            existing();
            __strong typeof(weakSelf) strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                block(strongSelf);
            });
        };
    } else {
        self.completionBlock = ^(){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                block(strongSelf);
            });
        };
    }
}

/**
 Add a completion block to be executed after the `NSOperation` enters the
 "finished" state.
 */
- (void)ins_addCompletionBlock:(void (^)(__kindof NSOperation *operation))block {
    if (!block) {
        return;
    }
    void (^existing)(void) = self.completionBlock;
    __weak typeof(self) weakSelf = self;
    if (existing) {
        /*
         If we already have a completion block, we construct a new one by
         chaining them together.
         */
        self.completionBlock = ^{
            existing();
            block(weakSelf);
        };
    } else {
        self.completionBlock = ^() {
            block(weakSelf);
        };
    }
}

- (void)ins_addCancelBlockInMainQueue:(nullable void(^)(__kindof NSOperation * _Nonnull operation))cancelBlock {
    if (!cancelBlock) {
        return;
    }
    [self ins_addCompletionBlockInMainQueue:^(__kindof NSOperation * _Nonnull operation) {
        if (cancelBlock && operation.isCancelled) {
            cancelBlock(operation);
        }
    }];
}

- (void)ins_addCancelBlock:(nullable void(^)(__kindof NSOperation * _Nonnull operation))cancelBlock {
    if (!cancelBlock) {
        return;
    }
    [self ins_addCompletionBlock:^(__kindof NSOperation * _Nonnull operation) {
        if (cancelBlock && operation.isCancelled) {
            cancelBlock(operation);
        }
    }];
}

/// Add multiple depdendencies to the operation.
- (void)ins_addDependencies:(NSArray <NSOperation *> *)dependencies {
    for (NSOperation *dependency in dependencies) {
        [self addDependency:dependency];
    }
}

@end
