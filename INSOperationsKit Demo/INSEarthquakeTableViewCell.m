//
//  INSEarthquakeTableViewCell.m
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 09.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import "INSEarthquakeTableViewCell.h"

@interface INSEarthquakeTableViewCell ()
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UILabel *timestampLabel;
@property (nonatomic, weak) IBOutlet UILabel *magnitudeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *magnitudeImage;
@end

@implementation INSEarthquakeTableViewCell

- (void)configureWithEarthquake:(INSEarthquake *)earthquake {
    self.locationLabel.text = earthquake.name;
    self.timestampLabel.text = [INSEarthquakeTimestampFormatter() stringFromDate:earthquake.timestamp];
    self.magnitudeLabel.text = [INSEarthquakeMagnitudeFormatter() stringFromNumber:earthquake.magnitude];
    
    NSString *imageName = nil;
    if ([earthquake.magnitude doubleValue] <= 2) {
        imageName = @"";
    } else if ([earthquake.magnitude doubleValue] > 2 && [earthquake.magnitude doubleValue] <= 3) {
        imageName = @"2.0";
    } else if ([earthquake.magnitude doubleValue] > 3 && [earthquake.magnitude doubleValue] <= 4) {
        imageName = @"3.0";
    } else if ([earthquake.magnitude doubleValue] > 4 && [earthquake.magnitude doubleValue] <= 5) {
        imageName = @"4.0";
    } else {
        imageName = @"5.0";
    }
    self.magnitudeImage.image = [UIImage imageNamed:imageName];
}
@end
