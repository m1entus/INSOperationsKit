//
//  INSBlockObserver.h
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INSOperationObserverProtocol.h"

typedef void(^INSBlockObserverStartHandler)(INSOperation *operation);
typedef void(^INSBlockObserverProduceHandler)(INSOperation *operation, NSOperation *producedOperation);
typedef void(^INSBlockObserverFinishHandler)(INSOperation *operation, NSArray *errors);

@interface INSBlockObserver : NSObject <INSOperationObserverProtocol>

- (instancetype)initWithStartHandler:(INSBlockObserverStartHandler)startHandler
                     produceHandler:(INSBlockObserverProduceHandler)produceHandler
                      finishHandler:(INSBlockObserverFinishHandler)finishHandler;

@end
