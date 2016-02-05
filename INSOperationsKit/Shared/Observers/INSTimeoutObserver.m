//
//  INSTimeoutObserver.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 04.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSTimeoutObserver.h"
#import "INSOperation.h"
#import "NSError+INSOperationKit.h"

@interface INSTimeoutObserver ()
@property (nonatomic, assign) NSTimeInterval timeout;
@end

@implementation INSTimeoutObserver

- (instancetype)initWithTimeout:(NSTimeInterval)interval {
    if (self = [super init]) {
        self.timeout = interval;
    }
    return self;
}

- (void)operationDidStart:(INSOperation *)operation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeout * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![operation isCancelled] && ![operation isFinished]) {
            NSError *error = [NSError ins_operationErrorWithCode:INSOperationErrorExecutionFailed
                                                        userInfo:@{ @"timeout" : @(self.timeout) }];
            [operation cancelWithError:error];
        }
    });
}

- (void)operationWillStart:(INSOperation *)operation inOperationQueue:(INSOperationQueue *)operationQueue {
    
}

- (void)operation:(INSOperation *)operation didProduceOperation:(NSOperation *)newOperation {
    // No operation.
}

- (void)operationDidFinish:(INSOperation *)operation errors:(NSArray *)errors {
    // No operation.
}
@end
