//
//  DSSpiderPlugin.m
//  ServicePlugin
//
//  Created by EriceWang on 2017/5/11.
//  Copyright © 2017年 Hangzhou Tree Finance Ltd. All rights reserved.
//

#import "TBSSpiderPlugin.h"
#import "TBSEnteranceController.h"
#import "NSString+URLEncoding.h"
#import <objc/message.h>
#import "Header.h"

@implementation TBSSpiderPlugin
- (void)resetTaskId:(NSDictionary *)command {
    __weak typeof (self.webview) weakWebview = self.webview;
    void(^refreshWebview)(void) = ^(){
        NSString *url = self.webview.request.URL.absoluteString;
        url = [url componentsSeparatedByString:@"?"].firstObject;
        url = [TBSUtil getUrlWithParams:url];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [weakWebview loadRequest:request];
    };
    NSString *deviceInfo = [TBSUtil deviceInfo];
    NSString *coorType = DS_GET(coorTypekey);
    NSString *uniqueId = DS_GET(uniqueIdKey);
    NSDictionary *params = @{@"uniqueId" : uniqueId, @"coorType" : coorType, @"deviceInfo" : deviceInfo};
    NSString *path = DS_GET(webLoginTypeKey);
    NSString *pathUrl = [NSString stringWithFormat:@"/%@/start", path];
    NSString *apiUrl = GET_SERVICE(pathUrl);
    [[TBSJSONUtil sharedInstance] getJSONAsync:apiUrl withData:params.tbs_getParasWithEncrypt method:@"POST" success:^(NSDictionary *data) {
        NSLog(@"content DATA = %@",data );
        NSDictionary *contentData = [data objectForKey:@"data"];
        NSDictionary *colors = [contentData objectForKey:@"color"];
        DS_SET(colorsKey, colors);
        NSString *taskId = [NSString stringWithFormat:@"%@", [contentData objectForKey:@"taskid"]];
        DS_SET(taskIdKey, taskId);
        refreshWebview();
        [self sendResult:command code:DSOperationStateSuccess result:nil];
    } error:^(NSError *error,id responseData) {
        NSLog(@"content DATA = %@ ", responseData);
        NSDictionary *contentData = [responseData objectForKey:@"data"];
        NSString *mark = [contentData objectForKey:@"mark"];
        NSString *title = [contentData objectForKey:@"title"];
        NSString *url = [contentData objectForKey:@"url"];
        NSString *errorMsg = [responseData objectForKey:@"errorMsg"];
        if (!url || !url.length) {
            url =GET_H5_URL(@"/exception");
        }
        if (!title || !title.length) {
            title = @"服务异常";
        }
        TBSEnteranceController *webview = [[TBSEnteranceController alloc] init];
        NSString *queryString = [NSString stringWithFormat:@"mark=%@&errorMsg=%@",mark?:@"", errorMsg?:@""];
        queryString = [queryString tbs_URLEncodedString];
        webview.startPage = [NSString stringWithFormat:@"%@?%@", url, queryString];
        webview.title = title;
        [self.viewController.navigationController pushViewController:webview animated:YES];
        [self sendResult:command code:DSOperationStateUnknownError result:nil];
    }];
}
- (void)setJSParams:(NSDictionary *)command {
    if (!command.count) {
        [self sendResult:command code:DSOperationStateParamsError result:nil];
    } else {
        DS_SET(paramsKey, command);
        [self sendResult:command code:DSOperationStateSuccess result:nil];
    }
}
- (void)cancel:(NSDictionary *)command {
    TreefinanceService *plugin = [TreefinanceService sharedInstance] ;
    SEL sel = NSSelectorFromString(@"backToApp");
    NSMethodSignature *sig = [plugin methodSignatureForSelector:sel];
    if (sig) {
        ((void(*)(id,SEL))objc_msgSend)(plugin, sel);
        [self sendResult:command code:DSOperationStateSuccess result:nil];
    } else {
        [self sendResult:command code:DSOperationStatePluginErrorMethod result:nil];
    }
}
- (void)callback:(NSDictionary *)command {
    NSInteger status = [[command objectForKey:@"status"] integerValue];
    NSString *params = [command objectForKey:@"params"];
    NSString *taskId = DS_GET(taskIdKey);
    NSString *uniqueId = DS_GET(uniqueIdKey);
    CallBackExecute callBack = [[TreefinanceService sharedInstance] valueForKey:@"_callBack"];
    if (callBack) {
        callBack(status, taskId, uniqueId, params);
        [self sendResult:command code:DSOperationStateSuccess result:nil];
    } else {
        [self sendResult:command code:DSOperationStatePluginErrorMethod result:nil];
    }
}

- (void)recoverScenes:(NSDictionary *)command {
    TreefinanceService *service = [TreefinanceService sharedInstance];
    SEL sel = NSSelectorFromString(@"recoverScenes");
    NSMethodSignature *sig = [service methodSignatureForSelector:sel];
    if (sig) {
        ((void(*)(id,SEL))objc_msgSend)(service, sel);
        [self sendResult:command code:DSOperationStateSuccess result:nil];
    } else {
        [self sendResult:command code:DSOperationStatePluginErrorMethod result:nil];
    }
}
@end
