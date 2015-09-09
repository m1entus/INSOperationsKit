//
//  INSGroupOperation.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 04.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSOperation.h"

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
+ (instancetype)operationWithOperations:(NSArray <NSOperation *> *)operations;
- (instancetype)initWithOperations:(NSArray <NSOperation *> *)operations;

- (void)addOperation:(NSOperation *)operation;
- (void)aggregateError:(NSError *)error;
- (void)operationDidFinish:(NSOperation *)operation withErrors:(NSArray <NSError *>*)errors;
@end
