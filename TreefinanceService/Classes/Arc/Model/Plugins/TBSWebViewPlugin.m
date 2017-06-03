//
//  DSWebViewPlugin.m
//  gongfubao
//
//  Created by EricyWang on 15/12/31.
//  Copyright (c) 2015年 Hangzhou Tree Finance Ltd. All rights reserved.
//

#import "TBSWebViewPlugin.h"
#import "TBSWebViewController.h"
#import "Header.h"
@implementation TBSWebViewPlugin
- (id) getParamFrom:(NSArray*)arguments atIndex:(NSInteger)index {
    id param = nil;
    if (index < [arguments count]) {
        param = [arguments objectAtIndex:index];
        if (param == [NSNull null]) {
            param = nil;
        }
    }
    return param;
}
-(void)bgColor:(NSDictionary *)command{
    NSString* bgColor=[command objectForKey:@"backgroundColor"];
    if (bgColor) {
        //        DS_SET(@"GLOBAL_WEBVIEW_BG_COLOR", bgColor);
        [self.webview.scrollView setBackgroundColor:[UIColor clearColor]];
        [self.webview setBackgroundColor:[UIColor clearColor]];
        self.viewController.view.backgroundColor = [UIColor tbs_colorWithHexString:bgColor alpha:1.0];
        self.viewController.view.backgroundColor = [UIColor tbs_colorWithHexString:bgColor alpha:1.0];
        //    [command.delegate sendPluginResult:command.successResult callbackId:command.callbackId];
        [self sendResult:command code:DSOperationStateSuccess result:nil];
    } else {
        [self sendResult:command code:DSOperationStateParamsError result:nil];
    }
    
}

-(void)clearCookies:(NSDictionary *)command{
    NSArray* cookies=[[NSHTTPCookieStorage sharedHTTPCookieStorage]cookies];
    NSLog(@"清空cookies前：%lu",(unsigned long)[[[NSHTTPCookieStorage sharedHTTPCookieStorage]cookies] count]);
    for (NSHTTPCookie* cookie in cookies) {
        if(cookie.domain&&![cookie.domain isEqual:[NSNull null]]&&[cookie.domain rangeOfString:@"91gfd"].location!=NSNotFound){
            //保留功夫贷的cookie
        }
        else{
            [[NSHTTPCookieStorage sharedHTTPCookieStorage]deleteCookie:cookie];
        }
        
    }
    NSLog(@"清空cookies后：%lu",(unsigned long)[[[NSHTTPCookieStorage sharedHTTPCookieStorage]cookies] count]);
    //    [command.delegate sendPluginResult:command.successResult callbackId:command.callbackId];
    [self sendResult:command code:DSOperationStateSuccess result:nil];
}

-(void)clearAllCookies:(NSDictionary *)command{
    NSArray* cookies=[[NSHTTPCookieStorage sharedHTTPCookieStorage]cookies];
    NSLog(@"清空cookies前：%lu",(unsigned long)[[[NSHTTPCookieStorage sharedHTTPCookieStorage]cookies] count]);
    for (NSHTTPCookie* cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage]deleteCookie:cookie];
    }
    NSLog(@"清空cookies后：%lu",(unsigned long)[[[NSHTTPCookieStorage sharedHTTPCookieStorage]cookies] count]);
    //    [command.delegate sendPluginResult:command.successResult callbackId:command.callbackId];
    [self sendResult:command code:DSOperationStateSuccess result:nil];
}

- (void)getCache:(NSDictionary *)command {
    NSString *str = [TBSUtil getCachesizeWithClearCaches:NO];
    [self sendResult:command code:DSOperationStateSuccess result:str];
}
- (void)clearCache:(NSDictionary *)command {
    [TBSUtil getCachesizeWithClearCaches:YES];
    [self sendResult:command code:DSOperationStateSuccess result:nil];
}
@end
