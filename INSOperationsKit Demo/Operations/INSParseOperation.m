//
//  INSParseOperation.m
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 07.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import "INSParseOperation.h"
#import "INSDownloadOperation.h"
#import "INSCoreDataStack.h"

@interface INSParseOperation ()
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) id responseToParse;
@property (nonatomic, strong) Class <INSCoreDataParsable> parsableClass;
@end

@implementation INSParseOperation

- (instancetype)initWithParsableClass:(Class <INSCoreDataParsable>)objectClass context:(NSManagedObjectContext *)context {
    if (self = [super init]) {
        self.parsableClass = objectClass;
        self.context = context;
    }
    return self;
}

- (void)execute {

    [self.context performBlock:^{
        
        if ([self.responseToParse isKindOfClass:[NSArray class]]) {
            [self.responseToParse enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * stop) {
                [self.parsableClass objectFromDictionary:obj inContext:self.context];
            }];
        } else if ([self.responseToParse isKindOfClass:[NSDictionary class]]) {
            [self.parsableClass objectFromDictionary:self.responseToParse inContext:self.context];
        }
        
        NSError *error = [INSCoreDataStack saveContext:self.context];
        [self finishWithError:error];
    }];
}

- (void)chainedOperation:(NSOperation *)operation didFinishWithErrors:(NSArray *)errors passingAdditionalData:(id)data {
    if ([operation isKindOfClass:[INSDownloadOperation class]] && data) {
        self.responseToParse = data;
    }
}

@end
