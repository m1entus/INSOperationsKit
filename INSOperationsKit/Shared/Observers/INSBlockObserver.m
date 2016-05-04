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
@property (nonatomic, copy) INSBlockObserverProduceHandler produceHandler;
@property (nonatomic, copy) INSBlockObserverFinishHandler cancelBeforeStartHandler;
@property (nonatomic, copy) INSBlockObserverFinishHandler finishHandler;
@end

@implementation INSBlockObserver

- (nonnull instancetype)initWithWillStartHandler:(INSBlockObserverWillStartHandler)willStartHandler
                         didStartHandler:(INSBlockObserverStartHandler)startHandler
                          produceHandler:(INSBlockObserverProduceHandler)produceHandler
                           finishHandler:(INSBlockObserverFinishHandler)finishHandler {
    return [self initWithWillStartHandler:willStartHandler didStartHandler:startHandler cancelBeforeStartHandler:nil produceHandler:produceHandler finishHandler:finishHandler];
}

- (nonnull instancetype)initWithWillStartHandler:(nullable INSBlockObserverWillStartHandler)willStartHandler
                                 didStartHandler:(nullable INSBlockObserverStartHandler)startHandler
                                   cancelBeforeStartHandler:(nullable INSBlockObserverFinishHandler)cancelBeforeStartHandler
                                  produceHandler:(nullable INSBlockObserverProduceHandler)produceHandler
                                   finishHandler:(nullable INSBlockObserverFinishHandler)finishHandler {
    if (self = [super init]){
        self.willStartHandler = willStartHandler;
        self.startHandler = startHandler;
        self.produceHandler = produceHandler;
        self.cancelBeforeStartHandler = cancelBeforeStartHandler;
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

- (void)operation:(INSOperation *)operation didProduceOperation:(NSOperation *)newOperation {
    if (self.produceHandler) {
        self.produceHandler(operation, newOperation);
    }
}

- (void)operationDidCancelBeforeStart:(nonnull INSOperation *)operation errors:(nullable NSArray <NSError *> *)errors {
    if (self.cancelBeforeStartHandler) {
        self.cancelBeforeStartHandler(operation,errors);
    }
}

- (void)operationDidFinish:(INSOperation *)operation errors:(NSArray <NSError *> *)errors {
    if (self.finishHandler){
        self.finishHandler(operation, errors);
    }
}

@end
