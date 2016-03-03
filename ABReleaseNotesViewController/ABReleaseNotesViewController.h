//
//  ABReleaseNotesViewController.h
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

#import <UIKit/UIKit.h>

/**
 
 Overview
 ====
 
 `ABReleaseNotesViewController` is a view controller, and should be the only part of this
 system with which you'll need to interact directly.
 
 You should generally instantiate `ABReleaseNotesViewController` with the factory class method
 provided here, instead of calling one of the `-init` methods. However, you can call one of the 
 `-init:` methods if you really want to, but take care to ensure that the properties set by the
 factory method are also set wherever you initialize your new view controller.
 
 Notes:
 ====
 
 * There is no guarantee that your block in `-checkForUpdates:` will ever be called. Do not assume it will be.
 
 Typical Usage
 ====
 
 Create your release notes object in your init method, or in `-viewDidLoad`:
 
     - (void)viewDidLoad {
         [super viewDidLoad];
         self.releaseNotes = [ABReleaseNotesViewController releaseNotesControllerWithAppIdentifier:@"329380089" title:NSLocalizedString(@"Release Notes", @"")];
     }
 
 After your view appears, begin checking for updates. If an update is available, you may present the view controller immediately, as depicted below:
 
    [self.releaseNotes checkForUpdates:^(BOOL updated) {
        if (updated) {
            [self presentViewController:self.releaseNotes animated:YES completion:nil];
        }
    }];
 
 Additionally, you could present an alert or some sort of non-modal user interface to the user informing them that they can read release notes if desired.
 */

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ABReleaseNotesViewControllerMode) {
    ABReleaseNotesViewControllerModeTesting = 0,
    ABReleaseNotesViewControllerModeProduction
};

@interface ABReleaseNotesViewController : UIViewController

/**
 The `mode` property controls whether the release notes controller always
 appears for testing purposes, or whether it only appears when an update
 has actually occurred. By default, this is set to `ABReleaseNotesViewControllerModeTesting`
 */
@property(nonatomic,assign) ABReleaseNotesViewControllerMode mode;

/**
 The style of the blur effect to apply to your view's background.
 */
@property(nonatomic,assign) UIBlurEffectStyle blurEffectStyle;

/**
 The title of the close button at the bottom of the view. By default, this is "Dismiss".
 */
@property(nonatomic,copy) NSString *closeButtonTitle;

/**
 Creates and returns a new view controller.
 
 @param appIdentifier The App Store identifier for your app.
 
 @return A newly initialized ABReleaseNotesViewController
 */
- (instancetype)initWithAppIdentifier:(NSString*)appIdentifier;

/**
 Checks the App Store to see if the current version of the app is an updated version.
 
 @param block The completion block called if an update has occurred.
 */
- (void)checkForUpdates:(void(^)(BOOL updated))block;
@end

NS_ASSUME_NONNULL_END
