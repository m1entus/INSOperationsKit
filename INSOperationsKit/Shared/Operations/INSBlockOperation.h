//
//  INSBlockOperation.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 04.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSOperation.h"

typedef void (^INSBlockOperationCompletionBlock)();
typedef void (^INSBlockOperationBlock)(INSBlockOperationCompletionBlock completionBlock);

/// A sublcass of `Operation` to execute a block.
@interface INSBlockOperation : INSOperation
@property (nonatomic, copy) INSBlockOperationBlock block;
/**
 The designated initializer.
 
 - parameter block: The closure to run when the operation executes. This
 closure will be run on an arbitrary queue. The parameter passed to the
 block **MUST** be invoked by your code, or else the `BlockOperation`
 will never finish executing. If this parameter is `nil`, the operation
 will immediately finish.
 */
- (instancetype)initWithBlock:(INSBlockOperationBlock)block;
+ (instancetype)operationWithBlock:(INSBlockOperationBlock)block;
/**
 A convenience initializer to execute a block on the main queue.
 
 - parameter mainQueueBlock: The block to execute on the main queue. Note
 that this block does not have a "continuation" block to execute (unlike
 the designated initializer). The operation will be automatically ended
 after the `mainQueueBlock` is executed.
 */
- (instancetype)initWithMainQueueBlock:(dispatch_block_t)block;
+ (instancetype)operationWithMainQueueBlock:(dispatch_block_t)block;

@end
