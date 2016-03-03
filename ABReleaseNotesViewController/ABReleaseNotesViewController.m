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
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UITextView *bodyText;
@property(nonatomic,copy) UIColor *lineViewColor;
@end

@implementation ABReleaseNotesViewController

- (instancetype)initWithAppIdentifier:(NSString*)appIdentifier {
    self = [super init];
    
    if (self) {
        self.title = NSLocalizedString(@"Release Notes", @"");

        _appIdentifier = [appIdentifier copy];
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;

    _mode = ABReleaseNotesViewControllerModeTesting;

    _blurEffectStyle = UIBlurEffectStyleLight;

    _closeButtonTitle = NSLocalizedString(@"Dismiss", @"");
    
    _lineViewColor = [UIColor colorWithWhite:0.f alpha:0.25f];

    // this has to be created in the initializer to ensure that, when the release notes
    // content is retrieved from the iTunes API, there is already a text view available
    // to plug the content into.
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

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.layer.shadowColor = [UIColor colorWithRed:0.f green:0.f blue:0.25f alpha:1.f].CGColor;
    self.view.layer.shadowOpacity = 0.25f;
    self.view.layer.shadowRadius = 8.f;

    UIButton *closeButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.25f];
        button.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        [button addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:self.closeButtonTitle forState:UIControlStateNormal];
        [button addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:0 constant:40]];

        button;
    });

    NSString *title = self.mode == ABReleaseNotesViewControllerModeProduction ? self.title : [NSString stringWithFormat:@"TESTING - %@", self.title];
    UINavigationBar *navigationBar = [self.class createNavigationBarWithTitle:title];

    NSArray *subviews = @[navigationBar, self.bodyText, [self.class makeLineViewWithColor:self.lineViewColor], closeButton];

    UIView *view = [self.class createEffectsViewsWithFrame:self.view.bounds blurEffectStyle:self.blurEffectStyle contentView:({
        UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:subviews];
        stackView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        stackView.axis = UILayoutConstraintAxisVertical;
        stackView;
    })];

    [self.view addSubview:view];
}

#pragma mark - Actions

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public Methods

- (void)checkForUpdates:(void(^)(BOOL updated))block {
    
    BOOL hasIdentifier = self.appIdentifier.length > 0;
    NSParameterAssert(hasIdentifier);
    if (!hasIdentifier) {
        return;
    }

    if (self.mode == ABReleaseNotesViewControllerModeProduction) {
        NSString *defaultsAppVersion = [[NSUserDefaults standardUserDefaults] objectForKey:ABReleaseNotesVersionUserDefaultsKey];
        if (!defaultsAppVersion) {
            // it's nil, so write out a value first launch and bail.
            [[NSUserDefaults standardUserDefaults] setObject:[self.class appVersionNumber] forKey:ABReleaseNotesVersionUserDefaultsKey];
            return;
        }

        if ([defaultsAppVersion isEqual:[self.class appVersionNumber]]) {
            // no new app version installed since last launch.
            return;
        }
    }

    // If we've gotten this far, then there's seemingly an update to tell the user about.
    self.downloader = [[ABReleaseNotesDownloader alloc] initWithAppIdentifier:self.appIdentifier];
    [self.downloader checkForUpdates:^(BOOL updated, NSString *releaseNotes, NSString *versionNumber) {
        if (self.mode == ABReleaseNotesViewControllerModeProduction && [versionNumber isEqual:[self.class appVersionNumber]]) {
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



+ (UINavigationBar*)createNavigationBarWithTitle:(NSString*)title {
    UINavigationBar *navigationBar = [[UINavigationBar alloc] init];
    [navigationBar pushNavigationItem:[[UINavigationItem alloc] initWithTitle:title] animated:YES];
    return navigationBar;
}

+ (UIView*)createEffectsViewsWithFrame:(CGRect)frame blurEffectStyle:(UIBlurEffectStyle)blurEffectStyle contentView:(UIView*)contentView {

    UIView *roundedCornerView = [[UIView alloc] initWithFrame:frame];
    roundedCornerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    roundedCornerView.clipsToBounds = YES;
    roundedCornerView.layer.cornerRadius = 8.f;

    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:blurEffectStyle];

    UIVisualEffectView *background = ({
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        effectView.frame = frame;
        effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        effectView;
    });
    [roundedCornerView addSubview:background];

    UIVisualEffectView *vibrancyView = ({
        UIVisualEffectView *v = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        v.frame = background.contentView.bounds;
        v.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        v;
    });
    [background.contentView addSubview:vibrancyView];

    contentView.frame = vibrancyView.contentView.bounds;
    [vibrancyView.contentView addSubview:contentView];

    return roundedCornerView;
}

@end
