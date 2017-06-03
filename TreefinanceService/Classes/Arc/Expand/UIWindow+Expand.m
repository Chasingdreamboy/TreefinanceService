//
//  UIWindow+Expand.m
//  gongfudai
//
//  Created by EriceWang Lan on 15/8/24.
//  Copyright (c) 2017年 dashu. All rights reserved.
//

#import "UIWindow+Expand.h"

@implementation UIWindow(Expand)
- (UIViewController *)tbs_visibleViewController {
    UIViewController *rootViewController = self.rootViewController;
    return [UIWindow getVisibleViewControllerFrom:rootViewController];
}
+ (UIWindow*)tbs_getWindow{
    NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication]windows]reverseObjectEnumerator];
    
    for (UIWindow *window in frontToBackWindows){
        if (window.windowLevel == UIWindowLevelNormal && !window.hidden) {
            return window;
        }
    }
    return [UIApplication sharedApplication].keyWindow;
}
+ (UIViewController *) getVisibleViewControllerFrom:(UIViewController *) vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [UIWindow getVisibleViewControllerFrom:[((UINavigationController *) vc) visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [UIWindow getVisibleViewControllerFrom:[((UITabBarController *) vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [UIWindow getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}

@end
