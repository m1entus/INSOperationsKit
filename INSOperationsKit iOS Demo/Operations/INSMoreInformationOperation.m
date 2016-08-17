//
//  INSMoreInformationOperation.m
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 13.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import "INSMoreInformationOperation.h"
#import "INSMutuallyExclusiveCondition.h"
@import SafariServices;

@interface INSMoreInformationOperation () <SFSafariViewControllerDelegate>

@end

@implementation INSMoreInformationOperation

- (instancetype)initWithURL:(NSURL *)URL presentationContext:(UIViewController *)presentationContext {
    if (self = [super init]) {
        _URL = URL;
        _presentationContext = presentationContext ?: [UIApplication sharedApplication].keyWindow.rootViewController;
        
        [self addCondition:[INSReachabilityCondition reachabilityCondition]];
        [self addCondition:[INSMutuallyExclusiveCondition viewControllerMutallyExclusive]];
        
        
    }
    return self;
}

- (void)execute {
    SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:self.URL];
    safariViewController.delegate = self;
    
    [self.presentationContext presentViewController:safariViewController animated:YES completion:nil];
}

#pragma mark - <SFSafariViewController>

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [self finish];
}

@end
