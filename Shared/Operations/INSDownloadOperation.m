//
//  INSDownloadOperation.m
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 07.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import "INSDownloadOperation.h"
#import "INSURLSessionTaskOperation.h"
#import "INSGroupOperation.h"
#import "INSParseOperation.h"
#import "INSEarthquake.h"
#import "INSChainOperation.h"
#import "INSReachabilityCondition.h"

@interface INSDownloadOperation ()
@property (nonatomic, strong) id responseData;
@property (nonatomic, strong) NSURL *URL;
@end

@implementation INSDownloadOperation

- (instancetype)initWithURL:(NSURL *)URL responseFiltering:(INSDownloadOperationResponseFilterBlock)responseFiltering {
    if (self = [super init]) {
        _URL = URL;
        _responseFilteringBlock = responseFiltering;
        
        [self addCondition:[INSReachabilityCondition reachabilityCondition]];
    }
    return self;
}

- (void)execute {

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.URL];
    NSURLSessionDataTask *task = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        if (error) {
            [self cancelWithError:error];
        } else {
            id response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            self.responseData = response;
            if (self.responseFilteringBlock) {
                self.responseData = self.responseFilteringBlock(response);
            }
            [self finish];
        }
    }];
    
    [task resume];
}

#pragma mark - <INSChainableOperationProtocol>

- (void)chainedOperation:(NSOperation *)operation didFinishWithErrors:(NSArray *)errors passingAdditionalData:(id)data {
    // Always first
}

- (id)additionalDataToPassForChainedOperation {
    return self.responseData;
}

@end
