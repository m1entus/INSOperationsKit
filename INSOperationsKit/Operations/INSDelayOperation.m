//
//  INSDelayOperation.m
//  INSOperationsKit Demo
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

- (instancetype)initWithDelayUntilDate:(NSDate *)date {
    if (self = [super init]) {
        self.delayDate = date;
    }
    return self;
}

- (void)execute {
    NSTimeInterval interval = self.delay;
    if (self.delayDate) {
        interval = [self.delayDate timeIntervalSinceNow];
    }
    
    if (self.delay <= 0) {
        [self finish];
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delay * NSEC_PER_SEC)), dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        if (![self isCancelled]) {
            [self finish];
        }
    });
}

- (void)cancel {
    [super cancel];
    [self finish];
}


@end
