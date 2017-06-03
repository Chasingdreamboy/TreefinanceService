//
//  MBProgressHUD.m
//  gongfudai
//
//  Created by EriceWang Lan on 15/7/24.
//  Copyright (c) 2017年 dashu. All rights reserved.
//

#import "MBProgressHUD+Expand.h"
#import "UIWindow+Expand.h"
#import "UIImage+ServicePlugin.h"
@implementation MBProgressHUD(Expand)

+(UIWindow*)tbs_getWindow{
    NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication]windows]reverseObjectEnumerator];
    
    for (UIWindow *window in frontToBackWindows){
        if (window.windowLevel == UIWindowLevelNormal && !window.hidden) {
            return window;
        }
    }
    return [UIApplication sharedApplication].keyWindow;
}


+(instancetype)showLoading:(NSString*)text{
    UIWindow* window=[self tbs_getWindow];
    MBProgressHUD* hud=[[MBProgressHUD alloc] initWithView:window];
    [window addSubview:hud];
    [hud showLoading:text];
    return hud;
}
+(instancetype)showSuccess:(NSString*)text withDuration:(NSTimeInterval)duration{
    UIWindow* window=[self tbs_getWindow];
    MBProgressHUD
    * hud=[[MBProgressHUD alloc]initWithView:window];
    [window addSubview:hud];
    [hud showSuccess:text withDuration:duration];
    return hud;
}
+(instancetype)showFail:(NSString*)text withDuration:(NSTimeInterval)duration{
    UIWindow* window=[self tbs_getWindow];
    MBProgressHUD* hud=[[MBProgressHUD alloc]initWithView:window];
    [window addSubview:hud];
    [hud showFail:text withDuration:duration];
    return hud;
}
-(void)showLoading:(NSString*)text{
    [self setMode:MBProgressHUDModeIndeterminate];
    self.label.text = text;
    [self showAnimated:YES];
//    self.labelText=text;
//    [self show:YES];
}
-(void)showSuccess:(NSString*)text{
    [self setMode:MBProgressHUDModeCustomView];
//    self.labelText=text;
    self.label.text = text;
    UIImage *image = [UIImage tbs_getImageWithName:@"fa-icon-success"];
    [self setCustomView:[[UIImageView alloc] initWithImage:image]];
//    [self show:YES];
    [self showAnimated:YES];
}
-(void)showSuccess:(NSString*)text withDuration:(NSTimeInterval)duration{
    [self showSuccess:text];
//    [self hide:YES afterDelay:duration];
    [self hideAnimated:YES afterDelay:duration];
}
-(void)showFail:(NSString*)text{
    [self setMode:MBProgressHUDModeCustomView];
//    self.labelText=text;
    self.label.text = text;
    UIImage* image=[UIImage tbs_getImageWithName:@"fa-icon-fail"];
    [self setCustomView:[[UIImageView alloc] initWithImage:image]];
//    [self show:YES];
    [self showAnimated:YES];
}
-(void)showFail:(NSString*)text withDuration:(NSTimeInterval)duration{
    [self showFail:text];
//    [self hide:YES afterDelay:duration];
    [self hideAnimated:YES afterDelay:duration];
}
@end
