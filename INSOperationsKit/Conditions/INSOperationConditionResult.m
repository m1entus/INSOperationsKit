//
//  INSOperationConditionResult.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSOperationConditionResult.h"
#import "INSOperationConditionProtocol.h"
#import "INSOperation.h"
#import "NSError+INSOperationKit.h"

@interface INSOperationConditionResult ()
@property (nonatomic, assign, getter=isSuccees) BOOL success;
@property (nonatomic, strong) NSError *error;
@end

@implementation INSOperationConditionResult

- (NSError *)error {
    if (!self.success) {
        return self.error;
    } else {
        return nil;
    }
}

+ (INSOperationConditionResult *)satisfiedResult {
    return [self resultWithSuccees:YES error:nil];
}

+ (INSOperationConditionResult *)failedResultWithError:(NSError *)error {
    return [self resultWithSuccees:NO error:error];
}

+ (INSOperationConditionResult *)resultWithSuccees:(BOOL)success error:(NSError *)error {
    INSOperationConditionResult *newResult = [[INSOperationConditionResult alloc] init];
    newResult.success = success;
    newResult.error = error;

    return newResult;
}

+ (void)evaluateConditions:(NSArray *)conditions operation:(INSOperation *)operation completion:(void (^)(NSArray *errors))completion {
    // Check conditions.
    dispatch_group_t conditionGroup = dispatch_group_create();

    //array of OperationConditionResult
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:conditions.count];

    // Ask each condition to evaluate and store its result in the "results" array.
    [conditions enumerateObjectsUsingBlock:^(NSObject<INSOperationConditionProtocol> *condition, NSUInteger idx, BOOL *stop) {
        
        dispatch_group_enter(conditionGroup);
        [condition evaluateForOperation:operation completion:^(INSOperationConditionResult * result) {
            
            results[idx] = result;
            dispatch_group_leave(conditionGroup);
        }];
    }];

    // After all the conditions have evaluated, this block will execute.
    dispatch_group_notify(conditionGroup, dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        // Aggregate the errors that occurred, in order.
        NSArray *failures = [[results filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"error != nil"]] valueForKeyPath:@"error"];
        
        /*
         If any of the conditions caused this operation to be cancelled,
         check for that.
         */
        if (operation.isCancelled) {
            failures = [failures arrayByAddingObject: [NSError ins_operationErrorWithCode:INSOperationErrorConditionFailed]];
        }
        if (completion){
            completion(failures);
        }
    });
}
@end
