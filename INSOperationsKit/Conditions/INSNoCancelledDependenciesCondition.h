//
//  INSNoCancelledDependenciesCondition.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 06.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INSOperationConditionProtocol.h"

extern NSString *const INSNoCancelledDependenciesConditionErrorDependenciesKey;

/**
 A condition that specifies that every dependency must have succeeded.
 If any dependency was cancelled, the target operation will be cancelled as
 well.
 */
@interface INSNoCancelledDependenciesCondition : NSObject <INSOperationConditionProtocol>

@end
