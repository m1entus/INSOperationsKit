//
//  ViewController.m
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 03.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//

#import "INSMainViewController.h"
#import "INSiOSEarthquakeOperationsProvider.h"
#import "INSEarthquake.h"
@import CoreData;
#import "INSEarthquakeTableViewCell.h"
#import "INSCoreDataStack.h"
@import CoreLocation;
#import "INSLocationAccessOperation.h"

@interface INSMainViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) CLLocation *currentLocation;
@end

@implementation INSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [[INSiOSEarthquakeOperationsProvider getAllEarthquakesWithCompletionHandler:^(INSChainOperation *operation, NSError *error){
        if (!error) {
            [self configureFetchedResultsController];
        }
    }] runInGlobalQueue];
	INSLocationAccessOperation *operation = [[INSLocationAccessOperation alloc] initWithUsage:INSLocationAccessUsageWhenInUse accuracy:kCLLocationAccuracyNearestTenMeters locationHandler:^(CLLocation *location) {
		self.currentLocation = location;
		[self.tableView reloadData];
	}];
	[operation runInGlobalQueue];
}

- (void)configureFetchedResultsController {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[INSEarthquake entityName]];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    fetchRequest.fetchLimit = 100;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[INSCoreDataStack sharedInstance] mainContext] sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"FETCHED ERROR %@",error);
    }
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedResultsController.sections[section] numberOfObjects];
}

- (UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    INSEarthquakeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    INSEarthquake *earthquake = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configureWithEarthquake:earthquake currentLocation:self.currentLocation];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    INSEarthquake *earthquake = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [[INSiOSEarthquakeOperationsProvider moreInformationForEarthquake:earthquake completionHandler:^(INSMoreInformationOperation *operation) {
        
    }] runInGlobalQueue];
}

@end
