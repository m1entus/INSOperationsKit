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
@end

@implementation INSURLSessionTaskOperation

- (instancetype)initWithTask:(NSURLSessionTask *)task {
    if (self = [super init]) {
        NSAssert(task.state == NSURLSessionTaskStateSuspended, @"Tasks must be suspended.");
        self.task = task;
    }
    return self;
}

+ (instancetype)operationWithTask:(NSURLSessionTask *)task {
    return [[[self class] alloc] initWithTask:task];
}

- (void)execute {
    if (self.isCancelled) {
        return;
    }
    
    NSAssert(self.task.state == NSURLSessionTaskStateSuspended, @"Task was resumed by sometion othen than %@.",NSStringFromClass([self class]));
    
    [self.task addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:INSDownloadOperationContext];
    [self.task resume];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != INSDownloadOperationContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if (object == self.task && [keyPath isEqualToString:@"state"] && self.task.state == NSURLSessionTaskStateCompleted) {
        [self.task removeObserver:self forKeyPath:@"state"];
        [self finish];
    }
}

- (void)cancel {
    [self.task cancel];
    [super cancel];
}

@end
