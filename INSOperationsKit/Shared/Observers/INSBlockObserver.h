//
//  INSBlockObserver.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INSOperationObserverProtocol.h"

typedef void(^INSBlockObserverWillStartHandler)(INSOperation *operation, INSOperationQueue *operationQueue);
typedef void(^INSBlockObserverStartHandler)(INSOperation *operation);
typedef void(^INSBlockObserverProduceHandler)(INSOperation *operation, NSOperation *producedOperation);
typedef void(^INSBlockObserverFinishHandler)(INSOperation *operation, NSArray <NSError *>*errors);

/**
 The `BlockObserver` is a way to attach arbitrary blocks to significant events
 in an `Operation`'s lifecycle.
 */
@interface INSBlockObserver : NSObject <INSOperationObserverProtocol>

- (instancetype)initWithWillStartHandler:(INSBlockObserverWillStartHandler)willStartHandler
                        didStartHandler:(INSBlockObserverStartHandler)startHandler
                     produceHandler:(INSBlockObserverProduceHandler)produceHandler
                      finishHandler:(INSBlockObserverFinishHandler)finishHandler;

@end
