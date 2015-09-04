//
//  INSOperationsKitTests.m
//  INSOperationsKitTests
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <INSOperationsKit/INSOperationsKit.h>
#import "INSOperationTestCondition.h"

@interface INSOperationsKitTests : XCTestCase
@property (nonatomic, strong) INSOperationQueue *operationQueue;
@end

@implementation INSOperationsKitTests

- (void)setUp {
    [super setUp];
    self.operationQueue = [[INSOperationQueue alloc] init];
}

- (void)tearDown {
    [super tearDown];
    [self.operationQueue cancelAllOperations];
    self.operationQueue = nil;
}

- (void)testStandardOperation {
    XCTestExpectation *expectation = [self expectationWithDescription:@"block"];
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [expectation fulfill];
    }];
    
    [self.operationQueue addOperation:operation];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testBlockOperationWithNoConditionsAndNoDependencies {
    XCTestExpectation *expectation = [self expectationWithDescription:@"block"];
    
    INSBlockOperation *operation = [[INSBlockOperation alloc] initWithBlock:^(INSBlockOperationCompletionBlock completionBlock) {
        [expectation fulfill];
    }];
    
    [self.operationQueue addOperation:operation];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testBlockOperationWithPassingConditionsAndNoDependencies {
    XCTestExpectation *expectation = [self expectationWithDescription:@"block"];
    
    INSBlockOperation *operation = [[INSBlockOperation alloc] initWithBlock:^(INSBlockOperationCompletionBlock completionBlock) {
        [expectation fulfill];
    }];
    
    [operation addCondition:[[INSOperationTestCondition alloc] initWithConditionBlock:^BOOL{
        return YES;
    }]];
    [self.operationQueue addOperation:operation];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testBlockOperationWithFailingConditionsAndNoDependencies {

    INSBlockOperation *operation = [[INSBlockOperation alloc] initWithBlock:^(INSBlockOperationCompletionBlock completionBlock) {
        XCTFail(@"Should not have run the block operation");
    }];
    
    [self keyValueObservingExpectationForObject:operation keyPath:@"isCancelled" handler:^BOOL(INSBlockOperation *observedObject, NSDictionary *change) {
        if (observedObject) {
            return observedObject.cancelled;
        }
        return NO;
    }];
    
    XCTAssertFalse(operation.cancelled, @"Should not yet have cancelled the operation");
    
    [operation addCondition:[[INSOperationTestCondition alloc] initWithConditionBlock:^BOOL{
        return NO;
    }]];
    [self.operationQueue addOperation:operation];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end
