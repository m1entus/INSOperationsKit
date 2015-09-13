//
//  ViewController.m
//  INSOperationsKit OSX
//
//  Created by Michal Zaborowski on 13.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import "INSOSXMainViewController.h"
#import "INSOSXEarthquakeOperationProvider.h"

@implementation INSOSXMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [[INSOSXEarthquakeOperationProvider getAllEarthquakesWithCompletionHandler:^(INSChainOperation *operation, NSError *error){
        if (!error) {
//            [self configureFetchedResultsController];
        }
    }] runInGlobalQueue];
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
