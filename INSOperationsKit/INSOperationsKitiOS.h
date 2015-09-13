//
//  INSOperationsKit.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for INSOperationsKit.
FOUNDATION_EXPORT double INSOperationsKitVersionNumber;

//! Project version string for INSOperationsKit.
FOUNDATION_EXPORT const unsigned char INSOperationsKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <INSOperationsKitiOS/PublicHeader.h>

#import <INSOperationsKitiOS/NSError+INSOperationKit.h>
#import <INSOperationsKitiOS/INSReachabilityManager.h>
#import <INSOperationsKitiOS/INSOperation.h>
#import <INSOperationsKitiOS/INSOperationQueue.h>
#import <INSOperationsKitiOS/INSOperationObserverProtocol.h>
#import <INSOperationsKitiOS/INSOperationConditionProtocol.h>
#import <INSOperationsKitiOS/INSOperationConditionResult.h>
#import <INSOperationsKitiOS/INSMutallyExclusiveCondition.h>
#import <INSOperationsKitiOS/INSReachabilityCondition.h>
#import <INSOperationsKitiOS/NSOperation+INSOperationKit.h>
#import <INSOperationsKitiOS/INSBlockOperation.h>
#import <INSOperationsKitiOS/INSGroupOperation.h>
#import <INSOperationsKitiOS/INSDelayOperation.h>
#import <INSOperationsKitiOS/INSURLSessionTaskOperation.h>
#import <INSOperationsKitiOS/INSOperationObserverProtocol.h>
#import <INSOperationsKitiOS/INSBlockObserver.h>
#import <INSOperationsKitiOS/INSTimeoutObserver.h>
#import <INSOperationsKitiOS/INSSilientCondition.h>
#import <INSOperationsKitiOS/INSNegatedCondition.h>
#import <INSOperationsKitiOS/INSChainOperation.h>
#import <INSOperationsKitiOS/INSNoCancelledDependenciesCondition.h>


