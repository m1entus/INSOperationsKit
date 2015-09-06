//
//  INSSilientCondition.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 06.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSSilientCondition.h"
#import "INSOperationConditionResult.h"

@interface INSSilientCondition ()
@property (nonatomic, strong) NSObject <INSOperationConditionProtocol> *condition;
@end

@implementation INSSilientCondition

- (instancetype)initWithCondition:(NSObject <INSOperationConditionProtocol> *)condition {
    if (self = [super init]) {
        self.condition = condition;
    }
    return self;
}

+ (instancetype)silientConditionForCondition:(NSObject <INSOperationConditionProtocol> *)condition {
    return [(INSSilientCondition *)[[self class] alloc] initWithCondition:condition];
}

#pragma mark - Subclass

- (NSString *)name {
    return [NSString stringWithFormat:@"%@<%@>", NSStringFromClass([INSSilientCondition class]), NSStringFromClass([self.condition class])];
}

- (BOOL)isMutuallyExclusive {
    return [self.condition isMutuallyExclusive];
}

- (NSOperation *)dependencyForOperation:(INSOperation *)operation {
    return nil;
}

- (void)evaluateForOperation:(INSOperation *)operation completion:(void (^)(INSOperationConditionResult *))completion {
    [self.condition evaluateForOperation:operation completion:completion];
}

@end
