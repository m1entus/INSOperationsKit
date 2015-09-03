//
//  INSBlockObserver.m
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSBlockObserver.h"

@interface INSBlockObserver ()
@property (nonatomic, copy) INSBlockObserverStartHandler startHandler;
@property (nonatomic, copy) INSBlockObserverProduceHandler produceHandler;
@property (nonatomic, copy) INSBlockObserverFinishHandler finishHandler;
@end

@implementation INSBlockObserver

- (instancetype)initWithStartHandler:(INSBlockObserverStartHandler)startHandler
                      produceHandler:(INSBlockObserverProduceHandler)produceHandler
                       finishHandler:(INSBlockObserverFinishHandler)finishHandler {
    if (self = [super init]){
        self.startHandler = startHandler;
        self.produceHandler = produceHandler;
        self.finishHandler = finishHandler;
    }
    return self;
}

#pragma mark - <INSOperationObserver>

- (void)operationDidStart:(INSOperation *)operation {
    if (self.startHandler) {
        self.startHandler(operation);
    }
}

- (void)operation:(INSOperation *)operation didProduceOperation:(NSOperation *)newOperation {
    if (self.produceHandler) {
        self.produceHandler(operation, newOperation);
    }
}

-(void)operationDidFinish:(INSOperation *)operation errors:(NSArray *)errors {
    if (self.finishHandler){
        self.finishHandler(operation, errors);
    }
}

@end
