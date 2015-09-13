//
//  INSOSXWebViewController.m
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 13.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import "INSOSXWebViewController.h"
@import WebKit;

@interface INSOSXWebViewController ()
@property (nonatomic, copy) INSOSXWebViewControllerCompletionHandler completionHandler;
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation INSOSXWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView = [WKWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidClose:) name:NSWindowWillCloseNotification object:nil];
}

- (void)loadPageWithURL:(NSURL *)URL completionHandler:(INSOSXWebViewControllerCompletionHandler)completion {
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];
    [self.webView loadRequest:request];
}

- (void)windowDidClose:(NSNotification *)note {
    if (note.object == self.view.window) {
        
    }
}


@end
