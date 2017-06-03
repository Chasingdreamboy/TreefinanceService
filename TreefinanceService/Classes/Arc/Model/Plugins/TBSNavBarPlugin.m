//
//  DSNavBarPlugin.m
//  gongfubao
//
//  Created by EricyWang on 15/12/31.
//  Copyright (c) 2015年 Hangzhou Tree Finance Ltd. All rights reserved.
//

#import "TBSNavBarPlugin.h"
#import "UIImage+Resize.h"
//#import "TBSWebImageManager.h"
//#import "SDWebImageManager.h"
#import <SDWebImage/SDWebImageManager.h>
#import "TBSEnteranceController.h"
#import <objc/message.h>
#import "Header.h"
@interface TBSNavBarPlugin()
{
    NSDictionary* currentLeftCommand;
    NSDictionary* currentRightCommand;
}
@end
@implementation TBSNavBarPlugin

-(void)setBarShow:(NSDictionary *)command{
    BOOL showNavigationBar = [[command objectForKey:@"showNavigationBar"] boolValue];
    BOOL animated= [[command objectForKey:@"animated"] boolValue];
    [self.viewController.navigationController setNavigationBarHidden:!showNavigationBar animated:animated];
    [self sendResult:command code:DSOperationStateSuccess result:nil];
}

-(void)setTitle:(NSDictionary *)command{
    NSString* title=[command objectForKey:@"title"];
    if (!title) {
        title = [command objectForKey:@"key"];
    }
    self.viewController.navigationItem.title=title;
    [self sendResult:command code:DSOperationStateSuccess result:nil];
}

-(void)setRightItem:(NSDictionary*)command{
    UIViewController* vc=self.viewController;
    NSString* imageUrl=[command objectForKey:@"url"];
    if (!imageUrl || !imageUrl.length) {
        vc.navigationItem.rightBarButtonItem = nil;
        return;
    }
    currentRightCommand=command;
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:imageUrl] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        NSString *tintColorString = DS_GET(tintColorKey);
        UIColor *tintColor = [UIColor tbs_colorWithHexString:tintColorString alpha:1.0];
        image = [image tbs_imageWithTintColor:tintColor];
        UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
        btnRight.frame = CGRectMake(0, 0, 46, 23);
        [btnRight setImage:image forState:UIControlStateNormal];
        [btnRight setImageEdgeInsets:UIEdgeInsetsMake(0, 13, 0, 10)];
        [btnRight addTarget:self action:@selector(eventRightItemClick:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
        [vc.navigationItem tbs_setRightBarButtonItem:rightItem];
    }];
    
}

-(void)setLeftItem:(NSDictionary*)command{
    UIViewController* vc=self.viewController;
    NSString* imageUrl=[command objectForKey:@"url"];
    if (!imageUrl || !imageUrl.length) {
        vc.navigationItem.leftBarButtonItem = nil;
        [self sendResult:command code:DSOperationStateParamsError result:nil];
        return;
    }
    currentLeftCommand=command;
    
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:imageUrl] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        NSString *tintColorString = DS_GET(tintColorKey);
        UIColor *tintColor = [UIColor tbs_colorWithHexString:tintColorString alpha:1.0];
        image = [image tbs_imageWithTintColor:tintColor];
        UIButton *btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnLeft setImage:image forState:UIControlStateNormal];
        [btnLeft setFrame:CGRectMake(0, 0, 46, 23)];
        [btnLeft setImageEdgeInsets:UIEdgeInsetsMake(-0.5, 0, -0.5, 23)];
        [btnLeft addTarget:self action:@selector(eventLeftItemClick:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
        [vc.navigationItem tbs_setLeftBarButtonItem:left];
    }];
}

-(void)eventRightItemClick:(id)sender{
    [self sendResult:currentRightCommand code:DSOperationStateSuccess result:nil];
    [self.webview stringByEvaluatingJavaScriptFromString:@"window.onNativeRightButtonClick()"];
}

-(void)eventLeftItemClick:(id)sender{
    BOOL isExist = [[self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"typeof (%@) == 'function'",@"window.onNativeLeftButtonClick"]] isEqualToString:@"true"];
    if (isExist) {
        [self.webview stringByEvaluatingJavaScriptFromString:@"window.onNativeLeftButtonClick()"];
    } else {
        if ([self.viewController isKindOfClass:[TBSEnteranceController class]]) {
            TreefinanceService *service = [TreefinanceService sharedInstance];
            SEL sel = NSSelectorFromString(@"backToApp");
            NSMethodSignature *sig = [service methodSignatureForSelector:sel];
            if (sig) {
                ((void(*)(id, SEL))objc_msgSend)(service, sel);
                NSLog(@"backToApp");
            } else {
                NSLog(@"backToApp not found!");
            }
        }
    }
     [self sendResult:currentLeftCommand code:DSOperationStateSuccess result:nil];
}
@end
