//
//  ViewController.m
//  ABReleaseNotesViewController
//
//  Created by Aaron Brethorst on 3/2/16.
//  Copyright © 2016 Aaron Brethorst. All rights reserved.
//

#import "ViewController.h"
#import "ABReleaseNotesViewController.h"

@interface ViewController ()
@property(nonatomic,strong) ABReleaseNotesViewController *releaseNotes;
@property(nonatomic,strong) UIWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Just a Web View", @"");

    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.apple.com"]]];

    self.releaseNotes = [ABReleaseNotesViewController releaseNotesControllerWithAppIdentifier:@"329380089" title:NSLocalizedString(@"Release Notes", @"")];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.releaseNotes checkForUpdates:^(BOOL updated) {
        if (updated) {
            [self presentViewController:self.releaseNotes animated:YES completion:nil];
        }
    }];
}
@end