//
//  INSBlockObserver.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INSOperationObserverProtocol.h"

typedef void(^INSBlockObserverWillStartHandler)(INSOperation * _Nonnull operation, INSOperationQueue * _Nonnull operationQueue);
typedef void(^INSBlockObserverStartHandler)(INSOperation * _Nonnull operation);
typedef void(^INSBlockObserverProduceHandler)(INSOperation * _Nonnull operation, NSOperation * _Nonnull producedOperation);
typedef void(^INSBlockObserverFinishHandler)(INSOperation * _Nonnull operation, NSArray <NSError *>* _Nullable errors);

/**
 The `BlockObserver` is a way to attach arbitrary blocks to significant events
 in an `Operation`'s lifecycle.
 */
@interface INSBlockObserver : NSObject <INSOperationObserverProtocol>

- (nonnull instancetype)initWithWillStartHandler:(nullable INSBlockObserverWillStartHandler)willStartHandler
                        didStartHandler:(nullable INSBlockObserverStartHandler)startHandler
                     produceHandler:(nullable INSBlockObserverProduceHandler)produceHandler
                      finishHandler:(nullable INSBlockObserverFinishHandler)finishHandler;

@end
