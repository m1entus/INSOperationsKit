//
//  INSMoreInformationOperation.h
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 13.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import <INSOperationsKit/INSOperationsKit.h>
@import UIKit;

@interface INSMoreInformationOperation : INSOperation
@property (nonatomic, strong) UIViewController *presentationContext;
@property (nonatomic, strong) NSURL *URL;

- (instancetype)initWithURL:(NSURL *)URL presentationContext:(UIViewController *)presentationContext;
@end
