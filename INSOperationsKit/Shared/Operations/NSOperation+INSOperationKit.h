//
//  NSOperation+INSOperationKit.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperation (INSOperationKit)

- (void)ins_addCompletionBlockInMainQueue:(nullable void (^)(__kindof NSOperation * _Nonnull operation))block NS_SWIFT_NAME(ins_addCompletionBlockInMainQueue(_:));
- (void)ins_addCompletionBlock:(nullable void (^)(__kindof NSOperation * _Nonnull operation))block;

- (void)ins_addCancelBlockInMainQueue:(nullable void(^)(__kindof NSOperation * _Nonnull operation))cancelBlock NS_SWIFT_NAME(ins_addCancelBlockInMainQueue(_:));
- (void)ins_addCancelBlock:(nullable void(^)(__kindof NSOperation * _Nonnull operation))cancelBlock;

- (void)ins_addDependencies:(nonnull NSArray <NSOperation *> *)dependencies;
@end
