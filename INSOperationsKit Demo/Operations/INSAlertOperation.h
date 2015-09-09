//
//  INSAlertOperation.h
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 09.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import <INSOperationsKit/INSOperationsKit.h>
@import UIKit;

@interface INSAlertOperation : INSOperation
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;

+ (instancetype)alertOperationWithPresentationContext:(UIViewController *)presentationContext;
- (void)addActionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(INSAlertOperation *operation))handler;
@end
