//
//  INSDelayOperation.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 04.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSDelayOperation.h"

@interface INSDelayOperation()
@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, strong) NSDate *delayDate;
@end

@implementation INSDelayOperation

- (instancetype)initWithDelay:(NSTimeInterval)delay {
    if (self = [super init]) {
        self.delay = delay;
    }
    return self;
}

+ (instancetype)operationWithDelay:(NSTimeInterval)delay {
    return [[[self class] alloc] initWithDelay:delay];
}

- (instancetype)initWithDelayUntilDate:(NSDate *)date {
    if (self = [super init]) {
        self.delayDate = date;
    }
    return self;
}

+ (instancetype)operationWithDelayUntilDate:(NSDate *)date {
    return [[[self class] alloc] initWithDelayUntilDate:date];
}

- (void)execute {
    NSTimeInterval interval = self.delay;
    if (self.delayDate) {
        interval = [self.delayDate timeIntervalSinceNow];
    }
    
    if (interval <= 0) {
        [self finish];
        return;
    }

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![self isCancelled]) {
            [self finish];
        }
    });
}

@end
