//
//  ViewController.m
//  INSOperationsKit tvOS Demo
//
//  Created by Michal Zaborowski on 13.11.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import "ViewController.h"
#import "INSDownloadOperation.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    INSDownloadOperation *downloadOperation = [[INSDownloadOperation alloc] initWithURL:[NSURL URLWithString:@"http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_month.geojson"] responseFiltering:^id(id responseObject) {
        return responseObject[@"features"];
    }];
    
    [downloadOperation runInGlobalQueue];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
