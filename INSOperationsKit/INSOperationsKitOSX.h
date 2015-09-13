//
//  INSOperationsKitOSX.h
//  INSOperationsKitOSX
//
//  Created by Michal Zaborowski on 13.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//! Project version number for INSOperationsKitOSX.
FOUNDATION_EXPORT double INSOperationsKitOSXVersionNumber;

//! Project version string for INSOperationsKitOSX.
FOUNDATION_EXPORT const unsigned char INSOperationsKitOSXVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <INSOperationsKitOSX/PublicHeader.h>

#import <INSOperationsKitOSX/NSError+INSOperationKit.h>
#import <INSOperationsKitOSX/INSReachabilityManager.h>
#import <INSOperationsKitOSX/INSOperation.h>
#import <INSOperationsKitOSX/INSOperationQueue.h>
#import <INSOperationsKitOSX/INSOperationObserverProtocol.h>
#import <INSOperationsKitOSX/INSOperationConditionProtocol.h>
#import <INSOperationsKitOSX/INSOperationConditionResult.h>
#import <INSOperationsKitOSX/INSMutallyExclusiveCondition.h>
#import <INSOperationsKitOSX/INSReachabilityCondition.h>
#import <INSOperationsKitOSX/NSOperation+INSOperationKit.h>
#import <INSOperationsKitOSX/INSBlockOperation.h>
#import <INSOperationsKitOSX/INSGroupOperation.h>
#import <INSOperationsKitOSX/INSDelayOperation.h>
#import <INSOperationsKitOSX/INSURLSessionTaskOperation.h>
#import <INSOperationsKitOSX/INSOperationObserverProtocol.h>
#import <INSOperationsKitOSX/INSBlockObserver.h>
#import <INSOperationsKitOSX/INSTimeoutObserver.h>
#import <INSOperationsKitOSX/INSSilientCondition.h>
#import <INSOperationsKitOSX/INSNegatedCondition.h>
#import <INSOperationsKitOSX/INSChainOperation.h>
#import <INSOperationsKitOSX/INSNoCancelledDependenciesCondition.h>