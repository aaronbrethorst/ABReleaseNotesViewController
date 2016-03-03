//
//  ABReleaseNotesPresentationController.m
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


#import "ABReleaseNotesPresentationController.h"

@interface ABReleaseNotesPresentationController ()
@property(nonatomic,strong) UIView *dimmingView;
@end

@implementation ABReleaseNotesPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];

    if (self) {
        _dimmingView = [[UIView alloc] initWithFrame:CGRectZero];
        _dimmingView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.05f];
    }
    return self;
}

- (void)presentationTransitionWillBegin {
    [super presentationTransitionWillBegin];
    self.dimmingView.frame = self.containerView.bounds;
    self.dimmingView.alpha = 0.f;
    [self.containerView insertSubview:self.dimmingView atIndex:0];

    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = 1.f;
    } completion:nil];
}


- (void)dismissalTransitionWillBegin {
    [super dismissalTransitionWillBegin];

    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = 0.f;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.dimmingView removeFromSuperview];
    }];
}

- (CGRect)frameOfPresentedViewInContainerView {
    if (self.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        // Phone size should be most of the screen.
        return CGRectInset(self.containerView.bounds, 30, 50);
    }
    else {
        // Tablet or TV, at least for now. Cap the size at something reasonable.
        CGRect rect = CGRectMake(0, 0, 400, 400);
        rect.origin = CGPointMake(self.containerView.center.x - 200.f, self.containerView.center.y - 200);
        return rect;
    }
}

- (void)containerViewWillLayoutSubviews {
    self.dimmingView.frame = self.containerView.bounds;
    self.presentedView.frame = [self frameOfPresentedViewInContainerView];
}
@end
