//
//  ViewController.m
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSMainViewController.h"
#import "INSDownloadEarthquakesOperation.h"
#import "INSOperationQueue.h"

@interface INSMainViewController ()
@property (nonatomic, strong) INSOperationQueue *operationQueue;
@end

@implementation INSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.operationQueue = [[INSOperationQueue alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.operationQueue addOperation:[[INSDownloadEarthquakesOperation alloc] initWithContext:nil completionHandler:nil]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
