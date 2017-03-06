//
//  UTANavController.m
//  UTALib
//
//  Created by David on 16/6/6.
//  Copyright © 2016年 UTA. All rights reserved.
//

#import "UTANavController.H"

#import "UTANavControllerDelegate.h"


@interface UTANavController () <UIGestureRecognizerDelegate, UINavigationControllerDelegate>
{
}

@end

@interface UINavigationController (topC)

- (UIViewController *)topC;

@end

@implementation UITabBarController (topC)

- (UIViewController *)topC {
    UIViewController *vc = self.selectedViewController;
    if ([vc isKindOfClass:[UINavigationController class]]) {
        vc = [(UINavigationController *)vc topC];
    }
    else if ([vc isKindOfClass:[UITabBarController class]]) {
        vc = [(UITabBarController *)vc topC];
    }
    return vc;
}

@end

@implementation UINavigationController (topC)

- (UIViewController *)topC {
    UIViewController *vc = self.topViewController;
    if ([vc isKindOfClass:[UINavigationController class]]) {
        vc = [(UINavigationController *)vc topC];
    }
    else if ([vc isKindOfClass:[UITabBarController class]]) {
        vc = [(UITabBarController *)vc topC];
    }
    return vc;
}

@end

@implementation UTANavController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id target = self.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:NSSelectorFromString(@"handleNavigationTransition:")];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    self.interactivePopGestureRecognizer.enabled = NO;
    self.delegate = self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [[self topC] preferredStatusBarStyle];
}

- (BOOL)shouldAutorotate {
    return [[self topC] shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [[self topC] supportedInterfaceOrientations];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    BOOL shouldBegin = NO;
    if ([self.topViewController respondsToSelector:@selector(navControlerShouldRecognizerGesture)]) {
        if (![(id<UTANavControllerDelegate>)self.topViewController navControlerShouldRecognizerGesture]) {
            return NO;
        }
    }
    do {
        if (self.viewControllers.count<=1) {
            break;
        }
        if (!self.view.userInteractionEnabled) {
            break;
        }
        if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view];
            if (velocity.x<=0 || fabs(velocity.y)>fabs(velocity.x)) {
                break;
            }
        }
        shouldBegin = YES;
    } while (NO);
    return shouldBegin;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    self.view.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.view.userInteractionEnabled = YES;
    });
}

@end
