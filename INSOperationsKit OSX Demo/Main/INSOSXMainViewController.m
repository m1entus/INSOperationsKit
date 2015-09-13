//
//  ViewController.m
//  INSOperationsKit OSX
//
//  Created by Michal Zaborowski on 13.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import "INSOSXMainViewController.h"
#import "INSOSXEarthquakeOperationProvider.h"
@import CoreData;
#import "SNRFetchedResultsController.h"
#import "INSEarthquake.h"
#import "INSCoreDataStack.h"

@interface INSOSXMainViewController () <NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) SNRFetchedResultsController *fetchedResultsController;
@end

@implementation INSOSXMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[INSOSXEarthquakeOperationProvider getAllEarthquakesWithCompletionHandler:^(INSChainOperation *operation, NSError *error){
        if (!error) {
            [self configureFetchedResultsController];
        }
    }] runInGlobalQueue];
    // Do any additional setup after loading the view.
}

- (void)configureFetchedResultsController {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[INSEarthquake entityName]];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    fetchRequest.fetchLimit = 100;
    
    self.fetchedResultsController = [[SNRFetchedResultsController alloc] initWithManagedObjectContext:[[INSCoreDataStack sharedInstance] mainContext] fetchRequest:fetchRequest];
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"FETCHED ERROR %@",error);
    }
    [self.tableView reloadData];
}

#pragma mark - <NSTableViewDataSource>

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *tableView = notification.object;
    __unused NSInteger selectedRowIndex = tableView.selectedRow;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.fetchedResultsController.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    INSEarthquake *earthquake = [self.fetchedResultsController objectAtIndex:row];
    
    if ([tableColumn.identifier isEqualToString:@"location"]) {
        return earthquake.name;
        
    } else if ([tableColumn.identifier isEqualToString:@"date"]) {
        return [INSEarthquakeTimestampFormatter() stringFromDate:earthquake.timestamp];
        
    } else if ([tableColumn.identifier isEqualToString:@"depth"]) {
        return [INSEarthquakeMagnitudeFormatter() stringFromNumber:earthquake.magnitude];
    }
    
    return nil;
}

@end
