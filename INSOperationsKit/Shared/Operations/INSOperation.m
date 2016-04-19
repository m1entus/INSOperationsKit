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

@property (nonatomic, strong) NSHashTable <INSOperation <INSChainableOperationProtocol> *> *chainedOperations;
@end

@implementation INSOperation
@synthesize cancelled = _cancelled;
@synthesize userInitiated = _userInitiated;
@synthesize state = _state;

// use the KVO mechanism to indicate that changes to "state" affect other properties as well
+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([@[ @"isReady" ] containsObject:key]) {
        return [NSSet setWithArray:@[ @"state", @"cancelledState" ]];
    }
    if ([@[ @"isExecuting", @"isFinished" ] containsObject:key]) {
        return [NSSet setWithArray:@[ @"state" ]];
    }
    if ([@[@"isCancelled"] containsObject:key]) {
        return [NSSet setWithArray:@[ @"cancelledState" ]];
    }
    
    return [super keyPathsForValuesAffectingValueForKey:key];
}

- (NSHashTable <INSOperation <INSChainableOperationProtocol> *> *)chainedOperations {
    if (!_chainedOperations) {
        _chainedOperations = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _chainedOperations;
}

- (INSOperationState)state {
    @synchronized(self) {
        return _state;
    }
}

- (void)setState:(INSOperationState)newState {
    // Manually fire the KVO notifications for state change, since this is "private".
    @synchronized(self) {
        if (_state != INSOperationStateFinished) {
            [self willChangeValueForKey:@"state"];
            NSAssert(_state != newState, @"Performing invalid cyclic state transition.");
            _state = newState;
            [self didChangeValueForKey:@"state"];
        }
    }
}

- (BOOL)isCancelled {
    return _cancelled;
}

- (void)setCancelled:(BOOL)cancelled {
    [self willChangeValueForKey:@"cancelledState"];
    _cancelled = cancelled;
    [self didChangeValueForKey:@"cancelledState"];
}

- (BOOL)isReady {
    BOOL ready = NO;
    
    @synchronized(self) {
        switch (self.state) {
            case INSOperationStateInitialized:
                ready = [self isCancelled];
                break;
                
            case INSOperationStatePending:
                if ([self isCancelled]) {
                    [self setState:INSOperationStateReady];
                    ready = YES;
                    break;
                }
                if ([super isReady]) {
                    [self evaluateConditions];
                }
                ready = (self.state == INSOperationStateReady && ([super isReady] || self.isCancelled));
                break;
            case INSOperationStateReady:
                ready = [super isReady] || [self isCancelled];
                break;
            default:
                ready = NO;
                break;
        }
    }
    
    return ready;
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
    
    if (!self.conditions.count) {
        self.state = INSOperationStateReady;
        return;
    }

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
        if ([observer respondsToSelector:@selector(operationWillStart:inOperationQueue:)]) {
            [observer operationWillStart:self inOperationQueue:operationQueue];
        }
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
        if ([observer respondsToSelector:@selector(operationDidStart:)]) {
            [observer operationDidStart:self];
        }
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
        if ([observer respondsToSelector:@selector(operation:didProduceOperation:)]) {
            [observer operation:self didProduceOperation:operation];
        }
    }
}

#pragma mark - Chaining

- (INSOperation <INSChainableOperationProtocol> *)chainWithOperation:(INSOperation <INSChainableOperationProtocol> *)operation {
    [self.chainedOperations addObject:operation];
    [operation addCondition:[INSChainCondition chainConditionForOperation:self]];
    
    __weak typeof(self) weakSelf = self;
    [operation addObserver:[[INSBlockObserver alloc] initWithWillStartHandler:nil didStartHandler:nil produceHandler:nil finishHandler:^(INSOperation *finishedOperation, NSArray<NSError *> *errors) {
        [weakSelf chainedOperation:finishedOperation didFinishWithErrors:errors passingAdditionalData:[finishedOperation additionalDataToPassForChainedOperation]];
    }]];
    
    return operation;
}

+ (void)chainOperations:(NSArray <INSOperation <INSChainableOperationProtocol> *>*)operations {
    [operations enumerateObjectsUsingBlock:^(INSOperation<INSChainableOperationProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger nextIndex = ++idx;
        if (nextIndex < operations.count) {
            [obj chainWithOperation:operations[nextIndex]];
        }
    }];
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
            if ([observer respondsToSelector:@selector(operationDidFinish:errors:)]) {
                [observer operationDidFinish:self errors:self.internalErrors];
            }
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
