
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
        completionBlock();
    }];
    
    [self.operationQueue addOperation:operation];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testBlockOperationWithPassingConditionsAndNoDependencies {
    XCTestExpectation *expectation = [self expectationWithDescription:@"block"];
    
    INSBlockOperation *operation = [[INSBlockOperation alloc] initWithBlock:^(INSBlockOperationCompletionBlock completionBlock) {
        [expectation fulfill];
        completionBlock();
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

- (void)testBlockOperationWithPassingConditionsAndConditionDependencyAndNoDependencies {
    XCTestExpectation *expectation = [self expectationWithDescription:@"block"];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"block2"];
    
    NSMutableArray *fulfilledExpectations = [NSMutableArray array];
    
    INSBlockOperation *operation = [[INSBlockOperation alloc] initWithBlock:^(INSBlockOperationCompletionBlock completionBlock) {
        [expectation fulfill];
        [fulfilledExpectations addObject:expectation];
        completionBlock();
    }];
    
    INSOperationTestCondition *condition = [[INSOperationTestCondition alloc] initWithConditionBlock:^BOOL{
        return YES;
    }];
    condition.dependencyOperation = [[INSBlockOperation alloc] initWithBlock:^(INSBlockOperationCompletionBlock completionBlock) {
        [expectation2 fulfill];
        [fulfilledExpectations addObject:expectation2];
        completionBlock();
    }];
    
    [operation addCondition:condition];
    [self.operationQueue addOperation:operation];
    
    NSArray *expectations = @[expectation,expectation2];
    
    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError *error) {
        XCTAssertEqual(fulfilledExpectations.count, expectations.count, @"Expectations fulfilled out of order");
    }];
}

- (void)testOperationWithNoConditionsAndHasDependency {
    XCTestExpectation *expectation = [self expectationWithDescription:@"block"];
    XCTestExpectation *expectationDependency = [self expectationWithDescription:@"block2"];
    
    NSMutableArray *fulfilledExpectations = [NSMutableArray array];
    
    INSBlockOperation *operation = [[INSBlockOperation alloc] initWithBlock:^(INSBlockOperationCompletionBlock completionBlock) {
        [expectation fulfill];
        [fulfilledExpectations addObject:expectation];
        completionBlock();
    }];
    
    INSBlockOperation *operationDependency = [[INSBlockOperation alloc] initWithBlock:^(INSBlockOperationCompletionBlock completionBlock) {
        [expectationDependency fulfill];
        [fulfilledExpectations addObject:expectationDependency];
        completionBlock();
    }];
    
    [operation addDependency:operationDependency];
    
    [self.operationQueue addOperation:operation];
    [self.operationQueue addOperation:operationDependency];
    
    NSArray *expectations = @[expectation,expectationDependency];
    
    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError *error) {
        XCTAssertEqual(fulfilledExpectations.count, expectations.count, @"Expectations fulfilled out of order");
    }];
}

- (void)testBlockOperationMissingCompletionBlockWithNoConditionsAndHasDependency {
    XCTestExpectation *expectationDependency = [self expectationWithDescription:@"block"];

    INSBlockOperation *operation = [[INSBlockOperation alloc] initWithBlock:^(INSBlockOperationCompletionBlock completionBlock) {
        XCTFail(@"Should not have run the block operation,");
    }];
    
    INSBlockOperation *operationDependency = [[INSBlockOperation alloc] initWithBlock:^(INSBlockOperationCompletionBlock completionBlock) {
        [expectationDependency fulfill];
    }];
    
    [operation addDependency:operationDependency];
    
    [self.operationQueue addOperation:operation];
    [self.operationQueue addOperation:operationDependency];
    

    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError *error) {
        XCTAssertNotEqual(operationDependency.state, INSOperationStateFinished, @"Expectations fulfilled out of order");
    }];
}

- (void)testGroupOperation {
    XCTestExpectation *expectation = [self expectationWithDescription:@"block"];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"block2"];
    
    NSOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        [expectation fulfill];
    }];
    
    NSOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        [expectation2 fulfill];
    }];
    
    INSGroupOperation *groupOperation = [[INSGroupOperation alloc] initWithOperations:@[operation1,operation2]];
    
    [self keyValueObservingExpectationForObject:groupOperation keyPath:@"isFinished" handler:^BOOL(INSBlockOperation *observedObject, NSDictionary *change) {
        if (observedObject) {
            return observedObject.finished;
        }
        return NO;
    }];
    
    [self.operationQueue addOperation:groupOperation];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testGroupOperationCancelBeforeExecuting {
    XCTestExpectation *expectation = [self expectationWithDescription:@"block"];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"block2"];
    
    NSOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        XCTFail(@"should not execute -- cancelled");
    }];
    
    operation1.completionBlock = ^{
        [expectation fulfill];
    };
    
    NSOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        XCTFail(@"should not execute -- cancelled");
    }];
    
    operation2.completionBlock = ^{
        [expectation2 fulfill];
    };
    
    INSGroupOperation *groupOperation = [[INSGroupOperation alloc] initWithOperations:@[operation1,operation2]];
    
    [self keyValueObservingExpectationForObject:groupOperation keyPath:@"isFinished" handler:^BOOL(INSBlockOperation *observedObject, NSDictionary *change) {
        if (observedObject) {
            return observedObject.finished;
        }
        return NO;
    }];
    
    self.operationQueue.suspended = YES;
    [self.operationQueue addOperation:groupOperation];
    [groupOperation cancel];
    self.operationQueue.suspended = NO;
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end
