//
//  INSOperationConditionProtocol.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//
@import Foundation;

@class INSOperation, INSOperationConditionResult;

/**
 A protocol for defining conditions that must be satisfied in order for an
 operation to begin execution.
 */
@protocol INSOperationConditionProtocol <NSObject>

/**
 The name of the condition. This is used in userInfo dictionaries of `.ConditionFailed`
 errors as the value of the `OperationConditionKey` key.
 */
- (nonnull NSString *)name;

/**
 Specifies whether multiple instances of the conditionalized operation may
 be executing simultaneously.
 */
- (BOOL)isMutuallyExclusive;

/**
 Some conditions may have the ability to satisfy the condition if another
 operation is executed first. Use this method to return an operation that
 (for example) asks for permission to perform the operation
 
 - parameter operation: The `Operation` to which the Condition has been added.
 - returns: An `NSOperation`, if a dependency should be automatically added. Otherwise, `nil`.
 - note: Only a single operation may be returned as a dependency. If you
 find that you need to return multiple operations, then you should be
 expressing that as multiple conditions. Alternatively, you could return
 a single `GroupOperation` that executes multiple operations internally.
 */
- (nullable NSOperation *)dependencyForOperation:(nonnull INSOperation *)operation;

/// Evaluate the condition, to see if it has been satisfied or not.
- (void)evaluateForOperation:(nonnull INSOperation *)operation completion:(nonnull void (^)(INSOperationConditionResult * _Nonnull result))completion;
@end
