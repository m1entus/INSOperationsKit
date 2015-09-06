//
//  INSURLSessionTaskOperation.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 04.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSOperation.h"

/**
 `URLSessionTaskOperation` is an `Operation` that lifts an `NSURLSessionTask`
 into an operation.
 
 Note that this operation does not participate in any of the delegate callbacks \
 of an `NSURLSession`, but instead uses Key-Value-Observing to know when the
 task has been completed. It also does not get notified about any errors that
 occurred during execution of the task.
 
 An example usage of `URLSessionTaskOperation` can be seen in the `DownloadEarthquakesOperation`.
 */
@interface INSURLSessionTaskOperation : INSOperation
@property (nonatomic, strong, readonly) NSURLSessionTask *task;
- (instancetype)initWithTask:(NSURLSessionTask *)task;
+ (instancetype)operationWithTask:(NSURLSessionTask *)task;
@end
