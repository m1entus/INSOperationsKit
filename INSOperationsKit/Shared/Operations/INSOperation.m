//
//  INSOperation.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSOperation.h"
#import "INSOperationConditionResult.h"
#import "INSOperationQueue.h"
#import "INSChainCondition.h"
#import "INSBlockObserver.h"

@interface INSOperation ()
@property (nonatomic, assign) BOOL hasFinishedAlready;
@property (nonatomic, assign) INSOperationState state;
@property (getter=isCancelled) BOOL cancelled;

@property (nonatomic, weak) INSOperationQueue *enqueuedOperationQueue;

@property (nonatomic, strong) NSArray <NSObject <INSOperationConditionProtocol> *> *conditions;
@property (nonatomic, strong) NSArray <NSObject <INSOperationObserverProtocol> *> *observers;
@property (nonatomic, strong) NSArray <NSError *> *internalErrors;
@end

@implementation INSOperation
@synthesize cancelled = _cancelled;
@synthesize userInitiated = _userInitiated;

// use the KVO mechanism to indicate that changes to "state" affect other properties as well
+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([@[ @"isReady", @"isExecuting", @"isFinished" ] containsObject:key]) {
        return [NSSet setWithArray:@[ @"state" ]];
    }
    if ([@[@"isCancelled"] containsObject:key]) {
        return [NSSet setWithArray:@[ @"canceledState" ]];
    }
    
    return [super keyPathsForValuesAffectingValueForKey:key];
}

- (void)setState:(INSOperationState)newState {
    // Manually fire the KVO notifications for state change, since this is "private".
    [self willChangeValueForKey:@"state"];

    // cannot leave the cancelled state
    // cannot leave the finished state
    if ( _state != INSOperationStateFinished) {
        NSAssert(_state != newState, @"Performing invalid cyclic state transition.");
        _state = newState;
    }

    [self didChangeValueForKey:@"state"];
}

- (BOOL)isCancelled {
    return _cancelled;
}

- (void)setCancelled:(BOOL)cancelled {
    [self willChangeValueForKey:@"canceledState"];
    _cancelled = cancelled;
    [self didChangeValueForKey:@"canceledState"];
}

- (BOOL)isReady {
    switch (self.state) {
    case INSOperationStatePending:
        if ([super isReady]) {
            [self evaluateConditions];
        }
        return false;
        break;
    case INSOperationStateReady:
        return [super isReady];
        break;
    default:
        return NO;
        break;
    }
}

- (BOOL)userInitiated {
    if ([self respondsToSelector:@selector(qualityOfService)]) {
        return self.qualityOfService == NSQualityOfServiceUserInitiated;
    }
    
    return _userInitiated;
}
- (void)setUserInitiated:(BOOL)newValue {
    NSAssert(self.state < INSOperationStateExecuting, @"Cannot modify userInitiated after execution has begun.");
    if ([self respondsToSelector:@selector(setQualityOfService:)]) {
        self.qualityOfService = newValue ? NSQualityOfServiceUserInitiated : NSQualityOfServiceDefault;
    }
    _userInitiated = newValue;
}
- (BOOL)isExecuting {
    return self.state == INSOperationStateExecuting;
}
- (BOOL)isFinished {
    return self.state == INSOperationStateFinished;
}

- (void)evaluateConditions {
    NSAssert(self.state == INSOperationStatePending, @"evaluateConditions() was called out-of-order");

    self.state = INSOperationStateEvaluatingConditions;

    [INSOperationConditionResult evaluateConditions:self.conditions operation:self completion:^(NSArray *failures) {
        
        if (failures.count != 0) {
            [self cancelWithErrors:failures];
        }
        //We must preceed to have the operation exit the queue
        self.state = INSOperationStateReady;
    }];
}

- (void)willEnqueueInOperationQueue:(INSOperationQueue *)operationQueue {
    self.enqueuedOperationQueue = operationQueue;
    
    for (NSObject<INSOperationObserverProtocol> *observer in self.observers) {
        [observer operationWillStart:self inOperationQueue:operationQueue];
    }
    
    self.state = INSOperationStatePending;
}

- (void)runInGlobalQueue {
    [[INSOperationQueue globalQueue] addOperation:self];
}

#pragma mark - Observers

- (NSArray *)observers {
    if (!_observers) {
        _observers = @[];
    }
    return _observers;
}

- (void)addObserver:(NSObject<INSOperationObserverProtocol> *)observer {
    NSAssert(self.state < INSOperationStateExecuting, @"Cannot modify observers after execution has begun.");
    self.observers = [self.observers arrayByAddingObject:observer];
}
#pragma mark - Conditions

- (NSArray *)conditions {
    if (!_conditions) {
        _conditions = @[];
    }
    return _conditions;
}

- (void)addCondition:(NSObject<INSOperationConditionProtocol> *)condition {
    NSAssert(self.state < INSOperationStateEvaluatingConditions, @"Cannot modify conditions after execution has begun.");
    self.conditions = [self.conditions arrayByAddingObject:condition];
}

- (void)addDependency:(NSOperation *)op {
    NSAssert(self.state <= INSOperationStateExecuting, @"Dependencies cannot be modified after execution has begun.");
    [super addDependency:op];
}

#pragma mark - Execution and Cancellation

- (void)start {
    NSAssert(self.state == INSOperationStateReady, @"This operation must be performed on an operation queue.");
    
    if (self.isCancelled) {
        [self finish];
        return;
    }
    self.state = INSOperationStateExecuting;

    for (NSObject<INSOperationObserverProtocol> *observer in self.observers) {
        [observer operationDidStart:self];
    }

    [self execute];
}

/**
 `execute()` is the entry point of execution for all `Operation` subclasses.
 If you subclass `Operation` and wish to customize its execution, you would
 do so by overriding the `execute()` method.
 
 At some point, your `Operation` subclass must call one of the "finish"
 methods defined below; this is how you indicate that your operation has
 finished its execution, and that operations dependent on yours can re-evaluate
 their readiness state.
 */
- (void)execute {
    NSLog(@"%@ must override `execute()`.", NSStringFromClass(self.class));
    [self finish];
}

- (void)cancel {
    if (self.isFinished) {
        return;
    }
    
    self.cancelled = YES;
    if (self.state > INSOperationStateReady) {
        [self finish];
    }
}

- (void)cancelWithErrors:(NSArray <NSError *> *)errors {
    self.internalErrors = [self.internalErrors arrayByAddingObjectsFromArray:errors];
    [self cancel];
}

- (void)cancelWithError:(NSError *)error {

    if (error) {
        self.internalErrors = [self.internalErrors arrayByAddingObject:error];
    }
    [self cancel];
}

- (void)produceOperation:(NSOperation *)operation {
    for (NSObject<INSOperationObserverProtocol> *observer in self.observers) {
        [observer operation:self didProduceOperation:operation];
    }
}

#pragma mark - Chaining

- (INSOperation <INSChainableOperationProtocol> *)chainWithOperation:(INSOperation <INSChainableOperationProtocol> *)operation {
    [operation addCondition:[INSChainCondition chainConditionForOperation:self]];
    
    __weak typeof(self) weakSelf = self;
    [operation addObserver:[[INSBlockObserver alloc] initWithWillStartHandler:nil didStartHandler:nil produceHandler:nil finishHandler:^(INSOperation *finishedOperation, NSArray<NSError *> *errors) {
        [weakSelf chainedOperation:finishedOperation didFinishWithErrors:errors passingAdditionalData:[finishedOperation additionalDataToPassForChainedOperation]];
    }]];
    
    __weak typeof(operation) weakOperation = operation;
    [self addObserver:[[INSBlockObserver alloc] initWithWillStartHandler:nil didStartHandler:^(INSOperation *operation) {
        NSAssert([operation.enqueuedOperationQueue.operations containsObject:weakOperation], @"You must first add operation which was chained to the operation queue!");
    } produceHandler:nil finishHandler:nil]];
    
    return operation;
}

- (void)chainedOperation:(NSOperation *)operation didFinishWithErrors:(NSArray <NSError *>*)errors passingAdditionalData:(id)data {
    // Implement in subclass
}

- (id)additionalDataToPassForChainedOperation {
    // Implement in subclass
    return nil;
}

#pragma mark - Finishing

- (NSArray *)internalErrors {
    if (!_internalErrors) {
        _internalErrors = @[];
    }
    return _internalErrors;
}

/**
 Most operations may finish with a single error, if they have one at all.
 This is a convenience method to simplify calling the actual `finish()`
 method. This is also useful if you wish to finish with an error provided
 by the system frameworks. As an example, see `DownloadEarthquakesOperation`
 for how an error from an `NSURLSession` is passed along via the
 `finishWithError()` method.
 */

- (void)finish {
    [self finishWithErrors:nil];
}

- (void)finishWithErrors:(NSArray <NSError *> *)errors {
    if (!self.hasFinishedAlready) {
        self.hasFinishedAlready = YES;
        self.state = INSOperationStateFinishing;

        _internalErrors = [self.internalErrors arrayByAddingObjectsFromArray:errors];
        [self finishedWithErrors:self.internalErrors];

        for (NSObject<INSOperationObserverProtocol> *observer in self.observers) {
            [observer operationDidFinish:self errors:self.internalErrors];
        }

        self.state = INSOperationStateFinished;
    }
}

- (void)finishWithError:(NSError *)error {
    if (error) {
        [self finishWithErrors:@[ error ]];
    } else {
        [self finish];
    }
}
/**
 Subclasses may override `finished(_:)` if they wish to react to the operation
 finishing with errors. For example, the `LoadModelOperation` implements
 this method to potentially inform the user about an error when trying to
 bring up the Core Data stack.
 */
- (void)finishedWithErrors:(NSArray <NSError *> *)errors {
    // No op.
}

- (void)waitUntilFinished {
    /*
     Waiting on operations is almost NEVER the right thing to do. It is
     usually superior to use proper locking constructs, such as `dispatch_semaphore_t`
     or `dispatch_group_notify`, or even `NSLocking` objects. Many developers
     use waiting when they should instead be chaining discrete operations
     together using dependencies.
     
     To reinforce this idea, invoking `waitUntilFinished()` will crash your
     app, as incentive for you to find a more appropriate way to express
     the behavior you're wishing to create.
     */
    NSAssert(NO, @"Waiting on operations is an anti-pattern. Remove this ONLY if you're absolutely sure there is No Other Way™.");
}

@end
