//
//  INSAlertOperation.m
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 09.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import "INSAlertOperation.h"
#import "INSMutallyExclusiveCondition.h"

@interface INSAlertOperation ()
@property (nonatomic, strong) UIViewController *presentationContext;
@property (nonatomic, strong) UIAlertController *alertController;
@end

@implementation INSAlertOperation

- (void)setTitle:(NSString *)title {
    _title = title;
    self.alertController.title = title;
}

- (void)setMessage:(NSString *)message {
    _message = message;
    self.alertController.message = message;
}

+ (instancetype)alertOperationWithPresentationContext:(UIViewController *)presentationContext {
    INSAlertOperation *alertOperation = [[INSAlertOperation alloc] init];
    alertOperation.presentationContext = presentationContext ?: [UIApplication sharedApplication].keyWindow.rootViewController;
    alertOperation.alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertOperation addCondition:[INSMutallyExclusiveCondition alertMutallyExclusive]];
    
    /*
     This operation modifies the view controller hierarchy.
     Doing this while other such operations are executing can lead to
     inconsistencies in UIKit. So, let's make them mutally exclusive.
     */
    [alertOperation addCondition:[INSMutallyExclusiveCondition viewControllerMutallyExclusive]];
    
    return alertOperation;
}

- (void)addActionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(INSAlertOperation *operation))handler {
    __weak typeof(self) weakSelf = self;
    [self.alertController addAction:[UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction * _Nonnull action) {
        if (handler) {
            handler(weakSelf);
        }
        [weakSelf finish];
    }]];
}

- (void)execute {
    if (!self.presentationContext) {
        [self finish];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.alertController.actions.count <= 0) {
            [self addActionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        }
        [self.presentationContext presentViewController:self.alertController animated:YES completion:nil];
    });
}

@end
