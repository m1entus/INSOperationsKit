//
//  INSBlockOperation.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 04.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSBlockOperation.h"

@interface INSBlockOperation ()
@end

@implementation INSBlockOperation

/**
 The designated initializer.
 
 - parameter block: The closure to run when the operation executes. This
 closure will be run on an arbitrary queue. The parameter passed to the
 block **MUST** be invoked by your code, or else the `BlockOperation`
 will never finish executing. If this parameter is `nil`, the operation
 will immediately finish.
 */
- (instancetype)initWithBlock:(INSBlockOperationBlock)block {
    if (self = [super init]) {
        self.block = block;
    }
    return self;
}

+ (instancetype)operationWithBlock:(INSBlockOperationBlock)block {
    return [[[self class] alloc] initWithBlock:block];
}

/**
 A convenience initializer to execute a block on the main queue.
 
 - parameter mainQueueBlock: The block to execute on the main queue. Note
 that this block does not have a "continuation" block to execute (unlike
 the designated initializer). The operation will be automatically ended
 after the `mainQueueBlock` is executed.
 */
- (instancetype)initWithMainQueueBlock:(dispatch_block_t)block {
    self = [self initWithBlock:^(void (^operationCompletionBlock)(void)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block();
            }
            if (operationCompletionBlock){
                operationCompletionBlock();
            }
        });
    }];
    return self;
}

+ (instancetype)operationWithMainQueueBlock:(dispatch_block_t)block {
    return [[[self class] alloc] initWithMainQueueBlock:block];
}

- (void)execute {
    INSBlockOperationCompletionBlock completion = ^{
        [self finish];
    };

    if (self.block) {
        self.block(completion);
    } else {
        completion();
    }
}

@end
