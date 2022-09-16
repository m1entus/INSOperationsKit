//
//  INSGroupOperation.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 04.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSOperation.h"

@class INSOperationQueue;

/**
 A subclass of `Operation` that executes zero or more operations as part of its
 own execution. This class of operation is very useful for abstracting several
 smaller operations into a larger operation. As an example, the `GetEarthquakesOperation`
 is composed of both a `DownloadEarthquakesOperation` and a `ParseEarthquakesOperation`.
 
 Additionally, `GroupOperation`s are useful if you establish a chain of dependencies,
 but part of the chain may "loop". For example, if you have an operation that
 requires the user to be authenticated, you may consider putting the "login"
 operation inside a group operation. That way, the "login" operation may produce
 subsequent operations (still within the outer `GroupOperation`) that will all
 be executed before the rest of the operations in the initial chain of operations.
 */
@interface INSGroupOperation : INSOperation
@property (nonatomic, strong, nonnull, readonly) INSOperationQueue *internalQueue;

+ (nonnull instancetype)operationWithOperations:(nonnull NSArray <NSOperation *> *)operations;
- (nonnull instancetype)initWithOperations:(nonnull NSArray <NSOperation *> *)operations;

- (void)addOperation:(nonnull NSOperation *)operation;
- (void)aggregateError:(nonnull NSError *)error;
- (void)operationDidFinish:(nonnull NSOperation *)operation withErrors:(nullable NSArray <NSError *>*)errors;
@end
