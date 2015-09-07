//
//  INSDownloadOperation.m
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 07.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import "INSDownloadEarthquakesOperation.h"
#import "INSURLSessionTaskOperation.h"
#import "INSGroupOperation.h"
#import "INSParseOperation.h"
#import "INSEarthquake.h"
#import "INSChainOperation.h"

@interface INSDownloadEarthquakesOperation ()
@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation INSDownloadEarthquakesOperation

- (instancetype)initWithContext:(NSManagedObjectContext *)context completionHandler:(void(^)())completionHandler {
    if (self = [super init]) {
        _context = context;
    }
    return self;
}

- (void)execute {
    
    __block INSURLSessionTaskOperation *sessionTaskOperation = nil;
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_month.geojson"]];
    NSURLSessionDataTask *task = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [self cancelWithError:error];
        } else {
//            NSError *error = nil;
//            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//            if (error) {
//                [self cancelWithError:error];
//            } else {
//                
//                INSParseOperation *parseOperation = [[INSParseOperation alloc] initWithResponseArrayObject:response[@"features"] parsableClass:[INSEarthquake class] context:self.context];
//                [sessionTaskOperation produceOperation:parseOperation];
//                
//                [parseOperation ins_addCompletionBlock:^{
//                    [self finish];
//                }];
//            }
        }
    }];
    
    INSParseOperation *parseOperation = [[INSParseOperation alloc] initWithResponseArrayObject:nil parsableClass:[INSEarthquake class] context:self.context];
    
    sessionTaskOperation = [INSURLSessionTaskOperation operationWithTask:task];
//    [self produceOperation:sessionTaskOperation];
    
    INSChainOperation *chail = [[INSChainOperation alloc] initWithOperations:@[sessionTaskOperation,parseOperation]];
    [self produceOperation:chail];
}

@end
