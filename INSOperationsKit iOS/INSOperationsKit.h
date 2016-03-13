//
//  INSOperationsKit.h
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 13.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

@import Foundation;

//! Project version number for INSOperationsKit.
FOUNDATION_EXPORT double INSOperationsKitVersionNumber;

//! Project version string for INSOperationsKit.
FOUNDATION_EXPORT const unsigned char INSOperationsKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <INSOperationsKit/PublicHeader.h>

#import <INSOperationsKit/NSError+INSOperationKit.h>
#import <INSOperationsKit/INSReachabilityManager.h>
#import <INSOperationsKit/INSChainCondition.h>
#import <INSOperationsKit/INSOperation.h>
#import <INSOperationsKit/INSOperationQueue.h>
#import <INSOperationsKit/INSOperationObserverProtocol.h>
#import <INSOperationsKit/INSOperationConditionProtocol.h>
#import <INSOperationsKit/INSOperationConditionResult.h>
#import <INSOperationsKit/INSMutallyExclusiveCondition.h>
#import <INSOperationsKit/INSReachabilityCondition.h>
#import <INSOperationsKit/INSLocationAccessCondition.h>
#import <INSOperationsKit/NSOperation+INSOperationKit.h>
#import <INSOperationsKit/INSBlockOperation.h>
#import <INSOperationsKit/INSGroupOperation.h>
#import <INSOperationsKit/INSDelayOperation.h>
#import <INSOperationsKit/INSURLSessionTaskOperation.h>
#import <INSOperationsKit/INSOperationObserverProtocol.h>
#import <INSOperationsKit/INSBlockObserver.h>
#import <INSOperationsKit/INSTimeoutObserver.h>
#import <INSOperationsKit/INSSilientCondition.h>
#import <INSOperationsKit/INSNegatedCondition.h>
#import <INSOperationsKit/INSChainOperation.h>
#import <INSOperationsKit/INSNoCancelledDependenciesCondition.h>
