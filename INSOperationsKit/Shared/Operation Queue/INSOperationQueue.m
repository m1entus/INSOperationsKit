//
//  INSOperationQueue.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSOperationQueue.h"
#import "INSOperation.h"
#import "NSOperation+INSOperationKit.h"
#import "INSBlockObserver.h"
#import "INSExclusivityController.h"

@interface INSOperationQueue ()
@property (nonatomic, strong) NSMutableSet *chainOperationsCache;
@property (nonatomic, strong) NSMutableSet <__kindof NSOperation *> *operationsCache;
@property (nonatomic, strong) dispatch_queue_t syncQueue;
@end

@implementation INSOperationQueue

- (NSMutableSet *)chainOperationsCache {
    @synchronized(self)
    {
        if (!_chainOperationsCache) {
            _chainOperationsCache = [NSMutableSet set];
        }
    }
    return _chainOperationsCache;
}

- (NSMutableSet *)operationsCache {
    @synchronized(self)
    {
        if (!_operationsCache) {
            _operationsCache = [NSMutableSet set];
        }
    }
    return _operationsCache;
}

- (NSArray<__kindof NSOperation *> *)operations {
    return [super operations];
}

- (nonnull NSArray<__kindof NSOperation *> *)addedOperations {
    __block NSArray<__kindof NSOperation *> *operations;

    dispatch_sync(self.syncQueue, ^{
        operations = [self.operationsCache allObjects];
    });

    return [operations copy];
}

+ (INSOperationQueue *)globalQueue {
    static INSOperationQueue *instanceOfGlobalQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceOfGlobalQueue = [[INSOperationQueue alloc] init];
    });
    return instanceOfGlobalQueue;
}

- (instancetype)init {
    if (self = [super init]) {
        _syncQueue = dispatch_queue_create("io.inspace.insoperationkit.insoperationqueue.sync", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)addOperation:(NSOperation *)operationToAdd {

    if ([self.addedOperations containsObject:operationToAdd]) {
        return;
    }
    
    if ([operationToAdd isKindOfClass:[INSOperation class]]) {
        INSOperation *operation = (INSOperation *)operationToAdd;
        
        // Chain operation cache is imporatant to be able to add any operation from chain
        // and whole chain will be added to queue
        __block BOOL hasChainedOperations = false;

        dispatch_sync(self.syncQueue, ^{
            hasChainedOperations = operation.chainedOperations.count > 0 && ![self.chainOperationsCache containsObject:operation];
        });

        if (hasChainedOperations && ![self.operations containsObject:operation]) {
            __block NSArray <INSOperation<INSChainableOperationProtocol> *> *chainedOperations;
            dispatch_sync(self.syncQueue, ^{
                [self.chainOperationsCache addObject:operation];
                chainedOperations = [operation.chainedOperations allObjects];
            });

            [chainedOperations enumerateObjectsUsingBlock:^(INSOperation<INSChainableOperationProtocol> * _Nonnull chainOperation, NSUInteger idx, BOOL * _Nonnull stop) {
                [self addOperation:chainOperation];
            }];
            
            return;
        }
        
        __weak typeof(self) weakSelf = self;
        // Set up a `BlockObserver` to invoke the `OperationQueueDelegate` method.
        INSBlockObserver *delegate = [[INSBlockObserver alloc]
                                      initWithWillStartHandler:nil
                                      didStartHandler:nil
                                      produceHandler:^(INSOperation *operation, NSOperation *producedOperation) {
            [weakSelf addOperation:producedOperation];

        } finishHandler:^(INSOperation *operation, NSArray *errors) {
            [weakSelf willChangeValueForKey:@"addedOperations"];
            dispatch_sync(self.syncQueue, ^{
                [weakSelf.operationsCache removeObject:operation];
                [weakSelf.chainOperationsCache removeObject:operation];
            });
            [weakSelf didChangeValueForKey:@"addedOperations"];

            if ([weakSelf.delegate respondsToSelector:@selector(operationQueue:operationDidFinish:withErrors:)]) {
                [weakSelf.delegate operationQueue:weakSelf operationDidFinish:operation withErrors:errors];
            }
        }];
        
        [operation addObserver:delegate];
        
        // Extract any dependencies needed by this operation.
        NSMutableArray *dependencies = [NSMutableArray arrayWithCapacity:operation.conditions.count];
        [operation.conditions enumerateObjectsUsingBlock:^(NSObject <INSOperationConditionProtocol> *condition, NSUInteger idx, BOOL *stop) {
             NSOperation *dependency = [condition dependencyForOperation:operation];
             if (dependency){
                 [dependencies addObject:dependency];
             }
         }];
        
        [dependencies enumerateObjectsUsingBlock:^(NSOperation *dependency, NSUInteger idx, BOOL *stop) {
            [operation addDependency:dependency];
            
            // Chain operation cache is imporatant to be able to add any operation from chain
            // and whole chain will be added to queue
            if ([dependency isKindOfClass:[INSOperation class]]) {
                INSOperation *dependencyOperation = (INSOperation *)dependency;
                if (dependencyOperation.chainedOperations.count > 0) {
                    dispatch_sync(self.syncQueue, ^{
                        [self.chainOperationsCache addObject:dependencyOperation];
                    });
                }
            }
            [self addOperation:dependency];
         }];
        
        /*
         With condition dependencies added, we can now see if this needs
         dependencies to enforce mutual exclusivity.
         */
        
        NSMutableArray *concurrencyCategories = [NSMutableArray array];
        
        [operation.conditions enumerateObjectsUsingBlock:^(NSObject <INSOperationConditionProtocol> *condition, NSUInteger idx, BOOL *stop){
            if ([condition isMutuallyExclusive]){
                [concurrencyCategories addObject:condition.name];
            }
        }];
        
        if (concurrencyCategories.count) {
            // Set up the mutual exclusivity dependencies.
            INSExclusivityController *exclusivityController = [INSExclusivityController sharedInstance];
            
            [exclusivityController addOperation:operation categories:concurrencyCategories];
            
            __weak typeof(exclusivityController) weakExclusivityController = exclusivityController;
            INSBlockObserver *observer = [[INSBlockObserver alloc]
                                      initWithWillStartHandler:nil
                                          didStartHandler:nil
                                          produceHandler:nil
                                          finishHandler:^(INSOperation *operation, NSArray *error) {
                                              [weakExclusivityController removeOperation:operation categories:concurrencyCategories];
                                      }];
            
            [operation addObserver:observer];
        }
        
        [operation willEnqueueInOperationQueue:self];
    } else {
        /*
         For regular `NSOperation`s, we'll manually call out to the queue's
         delegate we don't want to just capture "operation" because that
         would lead to the operation strongly referencing itself and that's
         the pure definition of a memory leak.
         */
        __weak typeof(self) weakSelf = self;
        __weak NSOperation * weakOperation = operationToAdd;
        [operationToAdd ins_addCompletionBlock:^(INSOperation *op){
            INSOperationQueue *operationQueue = weakSelf;
            NSOperation *operation = weakOperation;

            [weakSelf willChangeValueForKey:@"addedOperations"];
            dispatch_sync(self.syncQueue, ^{
                [weakSelf.operationsCache removeObject:operation];
            });
            [weakSelf didChangeValueForKey:@"addedOperations"];

            if (operationQueue && operation){
                if ([operationQueue.delegate respondsToSelector:@selector(operationQueue:operationDidFinish:withErrors:)]){
                    [operationQueue.delegate operationQueue:operationQueue operationDidFinish:operation withErrors:nil];
                }
            } else {
                return;
            }
        }];
    }
    if ([self.delegate respondsToSelector:@selector(operationQueue:willAddOperation:)]){
        [self.delegate operationQueue:self willAddOperation:operationToAdd];
    }

    [self willChangeValueForKey:@"addedOperations"];
    dispatch_sync(self.syncQueue, ^{
        [self.operationsCache addObject:operationToAdd];
    });
    [self didChangeValueForKey:@"addedOperations"];
    [super addOperation:operationToAdd];
}

- (void)addOperations:(NSArray<NSOperation *> *)operations waitUntilFinished:(BOOL)wait {
    /*
     The base implementation of this method does not call `addOperation()`,
     so we'll call it ourselves.
     */
    for (NSOperation *operation in operations) {
        if ([operation isKindOfClass:[NSOperation class]]) {
            [self addOperation:operation];
        }
    }

    if (wait) {
        for (NSOperation *operation in operations) {
            if ([operation isKindOfClass:[NSOperation class]]) {
                [operation waitUntilFinished];
            }
        }
    }
}
@end
