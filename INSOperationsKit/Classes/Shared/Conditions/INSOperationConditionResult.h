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
@property (nonatomic, readonly, nullable) NSError *error;

+ (nonnull INSOperationConditionResult *)satisfiedResult;
+ (nonnull INSOperationConditionResult *)failedResultWithError:(nonnull NSError *)error;

+ (void)evaluateConditions:(nonnull NSArray *)conditions operation:(nonnull INSOperation *)operation completion:(nullable void (^)(NSArray <NSError *>* _Nullable errors))completion;
@end
