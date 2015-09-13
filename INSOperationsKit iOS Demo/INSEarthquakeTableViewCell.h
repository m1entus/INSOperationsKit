//
//  INSEarthquakeTableViewCell.h
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 09.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INSEarthquake.h"

@interface INSEarthquakeTableViewCell : UITableViewCell
- (void)configureWithEarthquake:(INSEarthquake *)earthquake;
@end
