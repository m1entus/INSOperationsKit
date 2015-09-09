//
//  ViewController.m
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSMainViewController.h"
#import "INSDownloadOperation.h"
#import "INSOperationQueue.h"
#import "INSChainOperation.h"
#import "INSParseOperation.h"
#import "INSEarthquake.h"

@interface INSMainViewController ()
@property (nonatomic, strong) INSOperationQueue *operationQueue;
@end

@implementation INSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.operationQueue = [[INSOperationQueue alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
    
    INSDownloadOperation *downloadOperation = [[INSDownloadOperation alloc] initWithURL:[NSURL URLWithString:@"http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_month.geojson"] responseFiltering:^id(id responseObject) {
        return responseObject[@"features"];
    }];
    
    INSParseOperation *parseOperation = [[INSParseOperation alloc] initWithResponseArrayObject:nil parsableClass:[INSEarthquake class] context:nil];
    
    INSChainOperation *chainOperation = [[INSChainOperation alloc] initWithOperations:@[downloadOperation,parseOperation]];
    
    [self.operationQueue addOperation:chainOperation];
//    INS
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
