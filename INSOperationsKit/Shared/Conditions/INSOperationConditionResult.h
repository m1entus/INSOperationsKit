//
//  INSOperationConditionResult.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

@import Foundation;
@class INSOperation;

@interface INSOperationConditionResult : NSObject
@property (nonatomic, readonly, assign, getter=isSuccees) BOOL success;
@property (nonatomic, readonly) NSError *error;

+ (INSOperationConditionResult *)satisfiedResult;
+ (INSOperationConditionResult *)failedResultWithError:(NSError *)error;

+ (void)evaluateConditions:(NSArray *)conditions operation:(INSOperation *)operation completion:(void (^)(NSArray <NSError *>*errors))completion;
@end
