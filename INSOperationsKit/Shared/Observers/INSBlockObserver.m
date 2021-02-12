//
//  INSBlockObserver.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSBlockObserver.h"

@interface INSBlockObserver ()
@property (nonatomic, copy) INSBlockObserverWillStartHandler willStartHandler;
@property (nonatomic, copy) INSBlockObserverStartHandler startHandler;
@property (nonatomic, copy) INSBlockObserverStartHandler startExecutingHandler;
@property (nonatomic, copy) INSBlockObserverProduceHandler produceHandler;
@property (nonatomic, copy) INSBlockObserverFinishHandler finishHandler;
@end

@implementation INSBlockObserver

- (nonnull instancetype)initWithWillStartHandler:(INSBlockObserverWillStartHandler)willStartHandler
                         didStartHandler:(INSBlockObserverStartHandler)startHandler
                          produceHandler:(INSBlockObserverProduceHandler)produceHandler
                           finishHandler:(INSBlockObserverFinishHandler)finishHandler {
    if (self = [super init]){
        self.willStartHandler = willStartHandler;
        self.startHandler = startHandler;
        self.produceHandler = produceHandler;
        self.finishHandler = finishHandler;
    }
    return self;
}

- (nonnull instancetype)initWithWillStartHandler:(nullable INSBlockObserverWillStartHandler)willStartHandler
                                 didStartHandler:(nullable INSBlockObserverStartHandler)startHandler
                                 didStartExecutingHandler:(nullable INSBlockObserverStartHandler)startExecutingHandler
                                  produceHandler:(nullable INSBlockObserverProduceHandler)produceHandler
                                   finishHandler:(nullable INSBlockObserverFinishHandler)finishHandler {
    if (self = [super init]){
        self.willStartHandler = willStartHandler;
        self.startHandler = startHandler;
        self.produceHandler = produceHandler;
        self.startExecutingHandler = startExecutingHandler;
        self.finishHandler = finishHandler;
    }
    return self;
}

#pragma mark - <INSOperationObserver>

- (void)operationWillStart:(INSOperation *)operation inOperationQueue:(INSOperationQueue *)operationQueue {
    if (self.willStartHandler) {
        self.willStartHandler(operation,operationQueue);
    }
}

- (void)operationDidStart:(INSOperation *)operation {
    if (self.startHandler) {
        self.startHandler(operation);
    }
}

- (void)operationDidStartExecuting:(INSOperation *)operation {
    if (self.startExecutingHandler) {
        self.startExecutingHandler(operation);
    }
}

- (void)operation:(INSOperation *)operation didProduceOperation:(NSOperation *)newOperation {
    if (self.produceHandler) {
        self.produceHandler(operation, newOperation);
    }
}

- (void)operationDidFinish:(INSOperation *)operation errors:(NSArray <NSError *> *)errors {
    if (self.finishHandler){
        self.finishHandler(operation, errors);
    }
}

@end
