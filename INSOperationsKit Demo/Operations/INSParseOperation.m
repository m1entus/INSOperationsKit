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
@property (nonatomic, strong) NSArray *responseArray;
@property (nonatomic, strong) Class <INSCoreDataParsable> parsableClass;
@end

@implementation INSParseOperation

- (instancetype)initWithResponseArrayObject:(NSArray *)responseArray parsableClass:(Class <INSCoreDataParsable>)objectClass context:(NSManagedObjectContext *)context {
    if (self = [super init]) {
        self.responseArray = responseArray;
        self.parsableClass = objectClass;
        self.context = context;
    }
    return self;
}

- (void)execute {

    [self.context performBlock:^{
        
        [self.responseArray enumerateObjectsUsingBlock:^(NSDictionary  __nonnull *obj, NSUInteger idx, BOOL * __nonnull stop) {
            [self.parsableClass objectFromDictionary:obj inContext:self.context];
        }];
        
        NSError *error = [INSCoreDataStack saveContext:self.context];
        [self finishWithError:error];
    }];
}

- (void)chainedOperation:(NSOperation *)operation didFinishWithErrors:(NSArray *)errors passingAdditionalData:(id)data {
    if ([operation isKindOfClass:[INSDownloadOperation class]] && data) {
        self.responseArray = data;
    }
}

@end
