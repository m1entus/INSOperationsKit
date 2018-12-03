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
@end

@implementation INSOperationQueue

- (NSMutableSet *)chainOperationsCache {
    if (!_chainOperationsCache) {
        _chainOperationsCache = [NSMutableSet set];
    }
    return _chainOperationsCache;
}

+ (INSOperationQueue *)globalQueue {
    static INSOperationQueue *instanceOfGlobalQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceOfGlobalQueue = [[INSOperationQueue alloc] init];
    });
    return instanceOfGlobalQueue;
}

- (void)addOperation:(NSOperation *)operationToAdd {
    if ([self.operations containsObject:operationToAdd]) {
        return;
    }
    
    if ([operationToAdd isKindOfClass:[INSOperation class]]) {
        INSOperation *operation = (INSOperation *)operationToAdd;
        
        // Chain operation cache is imporatant to be able to add any operation from chain
        // and whole chain will be added to queue
        if (operation.chainedOperations.count > 0 && ![self.chainOperationsCache containsObject:operation] && ![self.operations containsObject:operation]) {
            [self.chainOperationsCache addObject:operation];
            [[operation.chainedOperations allObjects] enumerateObjectsUsingBlock:^(INSOperation<INSChainableOperationProtocol> * _Nonnull chainOperation, NSUInteger idx, BOOL * _Nonnull stop) {
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
                                           [weakSelf addOperation:producedOperation]; }
                                       finishHandler:^(INSOperation *operation, NSArray *errors) {
                                           __strong typeof(weakSelf) strongSelf = weakSelf;
                                           
                                           [strongSelf.chainOperationsCache removeObject:operation];
                                           
                                           if ([strongSelf.delegate respondsToSelector:@selector(operationQueue:operationDidFinish:withErrors:)]) {
                                               [strongSelf.delegate operationQueue:strongSelf operationDidFinish:operation withErrors:errors];
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
                    [self.chainOperationsCache addObject:dependencyOperation];
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
