//
//  NSOperation+INSOperationKit.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperation (INSOperationKit)

- (void)addCompletionBlock:(void (^)(void))block;
- (void)addDependencies:(NSArray /*NSOperation*/ *)dependencies;

@end
