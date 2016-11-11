//
//  INSURLSessionTaskOperation.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 04.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSURLSessionTaskOperation.h"

static void *INSDownloadOperationContext = &INSDownloadOperationContext;


@interface INSURLSessionTaskOperation ()
@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic) BOOL observerRemoved;
@end

@implementation INSURLSessionTaskOperation

- (instancetype)initWithTask:(NSURLSessionTask *)task {
    if (self = [super init]) {
        NSAssert(task.state == NSURLSessionTaskStateSuspended, @"Tasks must be suspended.");
        self.task = task;
        self.observerRemoved = NO;
    }
    return self;
}

+ (instancetype)operationWithTask:(NSURLSessionTask *)task {
    return [[[self class] alloc] initWithTask:task];
}

- (void)execute {
    if (self.isCancelled || self.task.state == NSURLSessionTaskStateCanceling) {
        [self finish];
        return;
    }

    NSAssert(self.task.state == NSURLSessionTaskStateSuspended, @"Task was resumed by something other than %@.",NSStringFromClass([self class]));

    [self.task addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:INSDownloadOperationContext];
    [self.task resume];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != INSDownloadOperationContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    if (!object) {
        return;
    }

    @synchronized (self) {
        if (object == self.task && [keyPath isEqualToString:@"state"] && !self.observerRemoved) {
            switch (self.task.state) {
                case NSURLSessionTaskStateCompleted:
                    [self finish];
                    // fallthrough

                case NSURLSessionTaskStateCanceling:
                    self.observerRemoved = YES;
                    [self.task removeObserver:self forKeyPath:@"state" context:context];

                default:
                    break;
            }
        }
    }
}

- (void)cancel {
    [self.task cancel];
    [super cancel];
}

@end
