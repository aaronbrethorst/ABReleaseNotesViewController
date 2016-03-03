//
//  ABReleaseNotesViewController.m
//
//  ABReleaseNotesViewController
//
//  Copyright (c) 2016 Aaron Brethorst
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


#import "ABReleaseNotesViewController.h"
#import "ABReleaseNotesPresentationController.h"
#import "ABReleaseNotesDownloader.h"

NSString * const ABReleaseNotesVersionUserDefaultsKey = @"ABReleaseNotesVersionUserDefaultsKey";

@interface ABReleaseNotesViewController ()<UIViewControllerTransitioningDelegate>
@property(nonatomic,copy) NSString *appIdentifier;
@property(nonatomic,strong) ABReleaseNotesDownloader *downloader;
@property(nonatomic,strong) UIView *contentView;
@property(nonatomic,strong) UIVisualEffectView *vibrancyView;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UITextView *bodyText;
@end

@implementation ABReleaseNotesViewController

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];

    if (self) {
        _blurEffectStyle = UIBlurEffectStyleLight;

        _closeButtonTitle = NSLocalizedString(@"Dismiss", @"");

        _lineViewColor = [UIColor colorWithWhite:0.f alpha:0.25f];

        _bodyText = ({
            UITextView *textView = [[UITextView alloc] init];
            textView.translatesAutoresizingMaskIntoConstraints = NO;
            textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            textView.backgroundColor = [UIColor clearColor];
            textView.editable = NO;
            textView.selectable = NO;
            textView;
        });
    }
    return self;
}

+ (id)releaseNotesControllerWithAppIdentifier:(NSString *)appIdentifier title:(NSString *)title {

    ABReleaseNotesViewController *controller = [[ABReleaseNotesViewController alloc] init];
    controller.title = title;
    controller.appIdentifier = appIdentifier;
    controller.blurEffectStyle = UIBlurEffectStyleLight;
    controller.modalPresentationStyle = UIModalPresentationCustom;
    controller.transitioningDelegate = controller;

    return controller;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.contentView.clipsToBounds = YES;
    [self.view addSubview:self.contentView];

    self.view.layer.shadowColor = [UIColor colorWithRed:0.f green:0.f blue:0.25f alpha:1.f].CGColor;
    self.view.layer.shadowOpacity = 0.25f;
    self.view.layer.shadowRadius = 8.f;
    self.view.layer.borderWidth = 1.f;
    self.view.layer.borderColor = self.lineViewColor.CGColor;
    [self createVisualEffectsViews];

    UINavigationBar *navigationBar = [[UINavigationBar alloc] init];
    [navigationBar pushNavigationItem:[[UINavigationItem alloc] initWithTitle:self.title] animated:YES];

    UIView *bottomEdge = [self.class makeLineViewWithColor:self.lineViewColor];

    UIButton *closeButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.25f];
        button.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        [button addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:self.closeButtonTitle forState:UIControlStateNormal];
        [button addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:0 constant:40]];

        button;
    });

    NSArray *subviews = @[navigationBar, self.bodyText, bottomEdge, closeButton];

    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:subviews];
    stackView.frame = self.vibrancyView.contentView.bounds;
    stackView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    stackView.axis = UILayoutConstraintAxisVertical;
    [self.vibrancyView.contentView addSubview:stackView];
}

- (void)createVisualEffectsViews {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:self.blurEffectStyle];

    UIVisualEffectView *background = ({
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        effectView.frame = self.view.bounds;
        effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        effectView;
    });
    [self.contentView addSubview:background];

    self.vibrancyView = ({
        UIVisualEffectView *v = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        v.frame = background.contentView.bounds;
        v.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        v;
    });
    [background.contentView addSubview:self.vibrancyView];
}

#pragma mark - Actions

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public Methods

- (void)checkForUpdates:(void(^)(BOOL updated))block {
    NSString *defaultsAppVersion = [[NSUserDefaults standardUserDefaults] objectForKey:ABReleaseNotesVersionUserDefaultsKey];
    if (!defaultsAppVersion) {
        // it's nil, so write out a value first launch and bail.
        [[NSUserDefaults standardUserDefaults] setObject:[self.class appVersionNumber] forKey:ABReleaseNotesVersionUserDefaultsKey];
        return;
    }

    // TODO: put me back!
//    if ([defaultsAppVersion isEqual:[self.class appVersionNumber]]) {
//        // no new app version installed since last launch.
//        return;
//    }

    // If we've gotten this far, then there's seemingly an update to tell the user about.
    self.downloader = [[ABReleaseNotesDownloader alloc] initWithAppIdentifier:self.appIdentifier];
    [self.downloader checkForUpdates:^(BOOL updated, NSString *releaseNotes, NSString *versionNumber) {
        if ([versionNumber isEqual:[self.class appVersionNumber]]) {
            // Belt and suspenders in case something went wrong.
            NSLog(@"We downloaded release notes, but the version in the App Store is identical to our local version!");
            NSLog(@"Local: %@ - App Store: %@", [self.class appVersionNumber], versionNumber);
            return;
        }

        self.bodyText.text = releaseNotes;

        block(updated);
    }];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return [[ABReleaseNotesPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

#pragma mark - Private

+ (NSString*)appVersionNumber {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
}

+ (UIView*)makeLineViewWithColor:(UIColor*)color {
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = color;
    [v addConstraint:[NSLayoutConstraint constraintWithItem:v attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:0 constant:1]];
    return v;
}
@end
