//
//  ViewController-Expand.m
//  gongfudai
//
//  Created by EriceWang Lan on 15/7/4.
//  Copyright (c) 2017年 dashu. All rights reserved.
//

#import "UIViewController+Expand.h"
#import "TBSWebViewController.h"
#import "NSObject+Swizzle.h"
#import <objc/runtime.h>
#import "Header.h"



static NSString *leftActionKey = @"leftAction";
static NSString *rightActionKey = @"rightAction";
@implementation UIViewController(Expand)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self tbs_swizzingSel:@selector(viewDidLoad) withSel:@selector(tbs_viewDidLoad)];
    });
}
- (void)tbs_viewDidLoad {
    //if this is a viewController in GFDSDK, we change its style.
    void(^executeBlockInOurController)() = ^() {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
        BOOL isSameStyleWithApp = [[[TreefinanceService sharedInstance] valueForKey:@"_isSameStyleWithApplication"] boolValue];
        if (isSameStyleWithApp) {
            UIColor *barTintColor = [[TreefinanceService sharedInstance] valueForKey:@"barTintColor"];
            NSDictionary *dic = [[TreefinanceService sharedInstance] valueForKey:@"attributes"];
            self.navigationController.navigationBar.barTintColor = barTintColor;
            self.navigationController.navigationBar.tintColor = [[TreefinanceService sharedInstance] valueForKey:@"tintColor"];
            self.navigationController.navigationBar.titleTextAttributes = dic;
        } else {
            NSString *barTintColorString = DS_GET(backgroundColorKey);
            NSString *tintColorString = DS_GET(tintColorKey);
            if (!barTintColorString || !barTintColorString.length) {
                barTintColorString = @"#070A15";
            }
            if (!tintColorString || !tintColorString.length) {
                tintColorString = @"#DBB76C";
            }
            UIColor *barTintColor = [UIColor tbs_colorWithHexString:barTintColorString alpha:1.0];
            UIColor *tintColor = [UIColor tbs_colorWithHexString:tintColorString alpha:1.0];
            self.navigationController.navigationBar.barTintColor = barTintColor;
            self.navigationController.navigationBar.tintColor = tintColor;
            self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
            self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName : tintColor};
        }
    };
    NSString *className = NSStringFromClass(self.class);
    //重新定义做返回按钮
    if ([className hasPrefix:@"TBS"]) {
        executeBlockInOurController();
        [self tbs_viewDidLoad];
    } else {
        [self tbs_viewDidLoad];
    }
    [self setNeedsStatusBarAppearanceUpdate];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    NSString *className = NSStringFromClass(self.class);
    if ([className hasPrefix:@"TBS"]) {
      return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
    
}
- (void)tbs_addLeftBackBtn:(void(^)(UIButton *sender))backAction {
    if (backAction) {
        objc_setAssociatedObject(self, &leftActionKey, backAction, OBJC_ASSOCIATION_COPY);
    }
    UIImage *image = [UIImage tbs_getImageWithName:@"btn-back-big@2x"];
    NSString *tintColorString = DS_GET(tintColorKey);
    if (!tintColorString || !tintColorString.length) {
        tintColorString = @"#DBB76C";
    }
    UIColor *tintColor = [UIColor tbs_colorWithHexString:tintColorString alpha:1.0];
    image = [image tbs_imageWithTintColor:tintColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(leftClickAction:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 46, 23);
    button.tintColor = tintColor;
    [button setImageEdgeInsets:UIEdgeInsetsMake(-0.5, 0, -0.5, 23)];
   UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem tbs_setLeftBarButtonItem:item];
}
- (void)leftClickAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    void(^block)(UIButton *sender) = objc_getAssociatedObject(self, &leftActionKey);
    if (block) {
        block(sender);
        NSLog(@"block= %@", block);
    } else {
        NSLog(@"block 为空");
    }
}

@end
