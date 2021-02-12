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
@property (nonatomic, strong) dispatch_source_t timeoutTimer;
@end

@implementation INSTimeoutObserver

- (void)dealloc {
    [self stopTimer];
}

- (instancetype)initWithTimeout:(NSTimeInterval)interval {
    if (self = [super init]) {
        self.timeout = interval;
    }
    return self;
}

- (void)operationDidStart:(INSOperation *)operation {
    
    dispatch_queue_t queue = dispatch_queue_create("io.inspace.insoperationkit.timeoutObserver", DISPATCH_QUEUE_CONCURRENT);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    self.timeoutTimer = timer;
    
    NSTimeInterval timeout = self.timeout;
    
    __weak typeof(operation) weakOperation = operation;
    __weak typeof(self) weakSelf = self;
    
    dispatch_source_set_event_handler(timer, ^{
        [weakSelf stopTimer];
        
        if (![weakOperation isCancelled] && ![weakOperation isFinished]) {
            NSError *error = [NSError ins_operationErrorWithCode:INSOperationErrorExecutionFailed
                                                        userInfo:@{ @"timeout" : @(timeout) }];
            [weakOperation cancelWithError:error];
        }
    });
    
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, timeout * NSEC_PER_SEC, 0);
    dispatch_resume(timer);
}

- (void)stopTimer {
    if (self.timeoutTimer && dispatch_testcancel(self.timeoutTimer) == 0) {
        dispatch_cancel(self.timeoutTimer);
    }
    self.timeoutTimer = nil;
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
