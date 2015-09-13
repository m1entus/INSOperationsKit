//
//  INSOSXWebViewController.h
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 13.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void(^INSOSXWebViewControllerCompletionHandler)();

@interface INSOSXWebViewController : NSViewController

- (void)loadPageWithURL:(NSURL *)URL completionHandler:(INSOSXWebViewControllerCompletionHandler)completion;

@end
