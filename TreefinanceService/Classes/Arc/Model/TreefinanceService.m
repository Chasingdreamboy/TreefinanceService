//
//  ServicePlugin.m
//  ServicePlugin
//
//  Created by EriceWang Lan on 15/11/10.
//  Copyright (c) 2017年 Hangzhou Tree Finance Ltd. All rights reserved.
//

#import "TreefinanceService.h"
#import "RKDropdownAlert.h"
#import <UIKit/UIKit.h>
#import "TBSWebViewController.h"
//#import "MBProgressHUD.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "TBSJSONUtil.h"
#import "TBSEnteranceController.h"
#import "UIImage+DivedeGitToImages.h"
#import "NSString+URLEncoding.h"
#import "TBSNavigationController.h"
#import "Header.h"

@interface TreefinanceService(){
    BOOL isHidden;
    NSDictionary *attributes;
    UIColor *barTintColor;
    UIColor *tintColor;
    NSArray *gestures;
    UIBarStyle barStyle;
    
    
    UIViewController *rootController;
    }
@property(nonatomic,readonly) NSString *appVersion;
@property (weak,nonatomic) UINavigationController* nav;
@property (assign, nonatomic)BOOL isSameStyleWithApplication;
@property (copy, nonatomic) CallBackExecute callBack;
@property (nonatomic, copy) void(^customersBlock)(NSDictionary *dic);//用作处理功夫贷壳应用与SDK通信

@end
static dispatch_once_t pred;
static TreefinanceService* instance;



@implementation TreefinanceService
//防止用户通过alloc或者copy方法获取对象
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
   return [TreefinanceService sharedInstance];
}
- (id)copy {
    return [TreefinanceService sharedInstance];
}

+(TreefinanceService*)sharedInstance{
    dispatch_once(&pred, ^{
        instance = [[super allocWithZone:NULL] init];
        //备份默认UserAgent
        if (DS_GET(@"originalUA")==nil) {
            NSString* ua=[[[UIWebView alloc]init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
            DS_SET(originalUAKey,ua);
        }
    });
    return instance;
}
- (NSString *)appVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
-(NSString*)sdkVersion{
  return [[TBS_BUNDLE infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
-(void)backToApp {
    DSLog(@"xx = %@", NSStringFromClass(rootController.class));
    
    @synchronized(rootController) {
        UIWindow *win = [UIWindow tbs_getWindow];
        win.rootViewController = rootController;
    }
    NSString *taskId = DS_GET(taskIdKey);
    NSString *apiUrl = GET_SERVICE(@"/task/cancel");
    NSLog(@"taskId = %@",taskId );
    if (!taskId) {
        NSLog(@"taskId 为空");
        return ;
    } else {
        NSDictionary *params = @{@"taskid" : taskId};
        [[TBSJSONUtil sharedInstance] getJSONAsync:apiUrl withData:params.tbs_getParasWithEncrypt method:@"POST" success:^(NSDictionary *data) {
            DSLog(@"/task/cancel接口返回数据成功:%@,taskId = %@", data, taskId);
        } error:^(NSError *error, id responseData) {
            DSLog(@"/task/cancel接口成功返回数据失败:%@, taskId = %@", responseData, taskId);
        }];
    }

}
- (void)initLocalData {
    DS_SET(uniqueIdKey, nil);
    DS_SET(positionKey, nil);
    DS_SET(queryStringKey, nil);
    DS_SET(coorTypekey, nil);
    DS_SET(webLoginTypeKey, nil);
    DS_SET(taskIdKey, nil);
    DS_SET(paramsKey, nil);
}
-(void)setupAPPID:(NSString*)appID appKey:(NSString*)appKey {
    BOOL invalidateAPPID = !appID || !appID.length;
    if (invalidateAPPID) {
        DSLog(@"抱歉,传入的appID不合法，请确认!");
        return ;
    }
    BOOL invalidateAPPKEY = !appKey || !appKey.length;
    if (invalidateAPPKEY) {
        DSLog(@"抱歉,传入的appKey不合法，请确认!");
        return;
    }
    _appID=appID;
    _appKey=appKey;
}
- (void)start:(nonnull NSString *)uniqueId latitude:(NSString *_Nullable)latitude longtitude:(NSString *_Nullable)longtitude coorType:(NSString *_Nullable) coorType appendParameters:(NSDictionary *_Nullable)parameters type:(DSWebLoginType) type extra:(NSDictionary *_Nullable)extra callback:(CallBackExecute)callback {
    [self initLocalData];
    self.callBack = callback;
    uniqueId = [NSString stringWithFormat:@"%@", uniqueId];
    BOOL invalidate = !uniqueId || !uniqueId.length;
    NSString *errorMsg = nil;
    if (invalidate) {
        errorMsg = [NSString stringWithFormat:@"Error:uniqueId参数不合法!!!%@", uniqueId];
        NSAssert(!invalidate, errorMsg);
    }
    BOOL validateType = (type | DSWebLoginTypeEmail) || (type | DSWebLoginTypeOperater) | (type | DSWebLoginTypeEcommerce);
    errorMsg =[NSString stringWithFormat:@"type参数不合法!!!!type = %@", @(type)] ;
    NSAssert(validateType, errorMsg);
    
    NSString *positionData = [NSString stringWithFormat:@"%@,%@",latitude ?:@"", longtitude?:@""];
    uniqueId = [NSString stringWithFormat:@"%@", uniqueId];
    DS_SET(uniqueIdKey, uniqueId);
    DS_SET(positionKey, positionData);
    DS_SET(queryStringKey, parameters.tbs_json);
    [TBSUtil getCachesizeWithClearCaches:YES];
    if (!coorType || !coorType.length) {
        coorType = @"wgs84ll";
    }
    DS_SET(coorTypekey, coorType);
    __block NSString *url = nil;
    NSString *title = nil;
    NSString *path = nil;
    switch (type) {
        case DSWebLoginTypeEmail:
            path = @"email";
            url = GET_H5_URL(@"/email");
            title = @"邮箱登录";
            break;
        case DSWebLoginTypeOperater:
            path = @"operator";
            url = GET_H5_URL(@"/operator") ;
            title = @"运营商登录";
            break;
        case DSWebLoginTypeEcommerce:
            path = @"ecommerce";
            url = GET_H5_URL(@"/ecommerce");
            title = @"电商登录";
            break;
        default:
            path = @"";
            title = @"参数错误";
            url = @"参数错误";
            break;
    }
    DS_SET(webLoginTypeKey, path);
    NSString *pathUrl = [NSString stringWithFormat:@"/%@/start", path];
    NSString *apiUrl = GET_SERVICE(pathUrl);
    NSString *deviceInfo = [TBSUtil deviceInfo];
    NSDictionary *params = nil;
    if (!extra || [extra isEqual:[NSNull null]]) {
        params = @{@"uniqueId" : uniqueId, @"coorType" : coorType, @"deviceInfo" : deviceInfo};
    } else {
        NSString *json = extra.tbs_json;
        params = @{@"uniqueId" : uniqueId, @"coorType" : coorType, @"deviceInfo" : deviceInfo, @"extra" : json ?: @""};
    }
//    DSLog(@"params = %@", params.tbs_getParasWithEncrypt);
    [[TBSJSONUtil sharedInstance] getJSONAsync:apiUrl withData:params.tbs_getParasWithEncrypt method:@"POST" success:^(NSDictionary *data) {
        
        NSLog(@"data responseData Q= %@", data );
        NSDictionary *contentData = [data objectForKey:@"data"];
        NSString *taskId = [NSString stringWithFormat:@"%@", [contentData objectForKey:@"taskid"]];
        DS_SET(taskIdKey, taskId);
        NSDictionary *colors = [contentData objectForKey:@"color"];
        DS_SET(colorsKey, colors);
        NSString *tintColorSDK = [colors objectForKey:@"backBtnAndFontColor"];
        NSString *backgroundColorSDK = [colors objectForKey:@"background"];
        NSString *btnColor = [colors objectForKey:@"main"];
        DS_SET(btnColorKey, btnColor);
        DS_SET(tintColorKey, tintColorSDK);
        DS_SET(backgroundColorKey, backgroundColorSDK);
        url = [TBSUtil getUrlWithParams:url];
        
        NSString *realTitle = [NSString stringWithFormat:@"%@", [contentData objectForKey:@"title"]] ;
        DSLog(@"realTitle = %@", realTitle);
        BOOL invalidate = !realTitle || [realTitle isEqual:[NSNull null]] || !realTitle.length || [realTitle isEqualToString:@"(null)"];
        if (invalidate) {
            realTitle = title;
        }
        [self pushController:url title:realTitle];
    } error:^(NSError *error, id responseData) {
        
        NSLog(@"data responseData = %@",responseData);
        NSDictionary *contentData = [responseData objectForKey:@"data"];
        NSString *mark = [contentData objectForKey:@"mark"];
        NSString *title = [contentData objectForKey:@"title"];
        NSString *url = [contentData objectForKey:@"url"];
        NSString *errorMsg = [responseData objectForKey:@"errorMsg"];
        if (!url || !url.length || [url isEqual:[NSNull null]]) {
            url = GET_H5_URL(@"/exception");
        }
        if (!title || !title.length || [title isEqual:[NSNull null]]) {
            title = @"服务异常";
        }
        NSString *queryString = [NSString stringWithFormat:@"mark=%@&errorMsg=%@",mark?:@"", errorMsg?:@""];
        queryString = [queryString tbs_URLEncodedString];
        NSString *urlString = [NSString stringWithFormat:@"%@?%@", url, queryString];
        [self pushController:urlString title:title];
    }];
}
- (void)pushController:(NSString *)url title:(NSString *)title {
    UIWindow *win = [UIWindow tbs_getWindow];
    rootController = win.rootViewController;
    TBSEnteranceController *web = [[TBSEnteranceController alloc] init];
    web.startPage = url;
    web.title = title;
    @synchronized (win) {
        win.rootViewController = ({
            TBSNavigationController *na = [[TBSNavigationController alloc] initWithRootViewController:web];
            na;
        });
    }
}
@end
