//
//  DSHookPlugin.m
//  gongfudai
//
//  Created by EriceWang on 16/5/5.
//  Copyright © 2016年 dashu. All rights reserved.
//
#import "TBSHookPlugin.h"
#import "TBSLoginHookViewController.h"
#import "TBSHideHookViewController.h"
#import "TBSJSONUtil.h"
#import "Header.h"
@implementation TBSHookPlugin
-(void)open:(NSDictionary *)command {
    
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if ([command isKindOfClass:[NSString class]]) {
            command = [(NSString *)command tbs_getSetFromJson];
        }
        TBSLoginHookViewController *login = [[TBSLoginHookViewController alloc] init];
        login.hidesBottomBarWhenPushed=YES;
        NSDictionary *httpConfig = [command objectForKey:@"httpConfig"];
        NSString *cookies = [httpConfig objectForKey:@"cookies"];
        if (cookies) {
            [login setCookies:cookies];
        }
        login.title=[command objectForKey:@"title"];
        [login setStartUrls:[command objectForKey:@"startUrl"]];
        login.startPage = [[command objectForKey:@"startUrl"] firstObject];
        [login setEndUrls:[command objectForKey:@"endUrl"]];
        [login setUsePCUA:[[command objectForKey:@"usePCUA"] boolValue]];
        [login setIdentifier:[command objectForKey:@"website"]];
        
        //支持post操作
        login.sendPost = [[command objectForKey:@"post"] boolValue];
        NSDictionary *postParams = [command objectForKey:@"postParams"];
        if (postParams) {
            login.postParams = postParams;
        }
        NSString *headers = [command objectForKey:@"header"];
        if (headers) {
            
        }
        [login setCss:[command objectForKey:@"css"]];
        [login setJs:[command objectForKey:@"js"]];
        BOOL saveCookie = NO;
        if (![dic objectForKey:@"saveCookie"]) {
            saveCookie = [[command objectForKey:@"saveCookie"] boolValue];
        }
        [login setSaveCookie:saveCookie];
        __weak typeof(self) weakSelf = self;
        [login setLoginSucces:^(TBSLoginHookViewController *vc, id params) {
            __strong id strongSelf=weakSelf;
            [strongSelf loginSuccess:params withCommand:command];
        }];
        [self.viewController.navigationController pushViewController:login animated:YES];

}

- (void)openHideView:(NSDictionary *)command {
    
    if ([command isKindOfClass:[NSString class]]) {
        command = [(NSString *)command tbs_getSetFromJson];
    }
    TBSHideHookViewController *login = [[TBSHideHookViewController alloc] init];
    
    login.hidesBottomBarWhenPushed=YES;
    login.title=[command objectForKey:@"title"];
    [login setStartUrls:[command objectForKey:@"startUrl"]];
    [login setEndUrls:[command objectForKey:@"endUrl"]];
    [login setUsePCUA:[[command objectForKey:@"usePCUA"] boolValue]];
    [login setIdentifier:[command objectForKey:@"website"]];
    //支持post操作
    login.sendPost = [[command objectForKey:@"post"] boolValue];
    NSDictionary *postParams = [command objectForKey:@"postParams"];
    if (postParams) {
        login.postParams = postParams;
    }
    NSDictionary *httpConfig = [command objectForKey:@"httpConfig"];
    NSString *cookies = [httpConfig objectForKey:@"cookies"];
    if (cookies) {
        [login setCookies:cookies];
    }
    NSArray *responseData = [httpConfig objectForKey:@"responseData"];
    if (responseData) {
        login.responseData = responseData;
    }
    NSString *visitType = [command objectForKey:@"visitType"];
    if ([visitType isEqualToString:@"url"]) {
        login.startPage=[[command objectForKey:@"startUrl"] objectAtIndex:0];
    } else if ([visitType isEqualToString:@"html"]) {
        login.startPage = [[command objectForKey:@"startUrl"] firstObject];
    }
    NSString *headers = [httpConfig objectForKey:@"header"];
    if (headers) {
        
    }
    NSString *proxy = [httpConfig objectForKey:@"proxy"];
    if (proxy) {
        
    }
    login.hiddeView = YES;
    login.view.hidden = YES;
    login.loginSucces = ^(TBSHideHookViewController *vc, NSDictionary *params){
        [vc removeFromParentViewController];
        [vc.view removeFromSuperview];
        [self sendCookiesAndHtml:params withCommand:command];
    };
    [self.viewController addChildViewController:login];
    [self.viewController.view addSubview:login.view];
}
- (void)sendCookiesAndHtml:(NSDictionary *)params withCommand:(NSDictionary *)commadn {
    NSString *typeString = DS_GET(webLoginTypeKey);
    if ([typeString isEqualToString:@"operator"]) {
        //operator使用模拟登录，不需要发送cookie
        return;
    }
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:params];
    NSString *taskId = DS_GET(taskIdKey);
    [mutableDic setObject:taskId forKey:@"taskid"];
    NSString *directiveId = [commadn objectForKey:@"directiveId"];
    if (directiveId) {
        [mutableDic setObject:directiveId forKey:@"directiveId"];
    }
    
    NSLog(@"params = %@", mutableDic);
    NSString *pathUrl = [NSString stringWithFormat:@"/%@/acquisition/process", typeString];
    NSString *apiUrl = GET_SERVICE(pathUrl);
    [[TBSJSONUtil sharedInstance] getJSONAsync:apiUrl withData:mutableDic.tbs_getParasWithEncrypt method:@"POST" success:^(NSDictionary *data) {
        [self sendResult:commadn code:DSOperationStateSuccess result:nil];
    } error:^(NSError *error, id responseData) {
        [self sendResult:commadn code:DSOperationStateUnknownError result:nil];
    }];
}
/**
 *  上传cookies
 *
 *  @param cookies 参数字典
 */
-(void)loginSuccess:(NSDictionary*)cookies withCommand:(NSDictionary *)command {
    if([self.viewController.navigationController.topViewController isKindOfClass:[TBSLoginHookViewController class]]){
        [self.viewController.navigationController popViewControllerAnimated:YES];
    }
    [self uploadCollection:cookies finish:^(BOOL success, id msg) {
        if (success) {
            [self sendResult:command code:DSOperationStateSuccess result:nil];
        } else {
            [self sendResult:command code:DSOperationStateNetFail result:msg];
        }
    }];
}
- (void)uploadCollection:(NSDictionary *)cookies finish:(void(^)(BOOL success, id reponseObject))finish {
    MBProgressHUD* hud=[MBProgressHUD showLoading:@"正在验证"];
    NSString *typeString = DS_GET(webLoginTypeKey);
    if ([typeString isEqualToString:@"operator"]) {
        //operator使用模拟登录，不需要发送cookie
        return;
    }
    NSString *taskId = DS_GET(taskIdKey);
    NSDictionary *exterDic = DS_GET(paramsKey);
    NSString *pathUrl = [NSString stringWithFormat:@"/%@/%@",typeString, @"acquisition"];
    NSString *apiUrl = GET_SERVICE(pathUrl);
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:cookies];
    if (taskId) {
        [params setObject:taskId forKey:@"taskid"];
    }
    if (exterDic) {
        [params addEntriesFromDictionary:exterDic];
//        [[[UIAlertView alloc] initWithTitle:@"测试弹窗" message:exterDic.sdk_json delegate:nil cancelButtonTitle:@"点击取消" otherButtonTitles: nil] show];
    } else {
//        [[[UIAlertView alloc] initWithTitle:@"测试弹窗" message:@"未获取到accountNO" delegate:nil cancelButtonTitle:@"点击取消" otherButtonTitles: nil] show];
        
    }
    [[TBSJSONUtil sharedInstance]getJSONAsync:apiUrl withData:params.tbs_getParasWithEncrypt method:@"POST" success:^(NSDictionary *data) {
        [hud showSuccess:@"验证请求已提交，请耐心等待" withDuration:DEFAULT_DISMISS_TIMEUOT];
        if (finish) {
            finish(YES, nil);
        }
    } error:^(NSError *error, id responseData) {
        if (finish) {
            finish(NO, nil);
        }
        NSString *msg = nil;
        if ([responseData isKindOfClass:[NSDictionary class]]) {
            msg = [responseData objectForKey:@"errorMsg"];
            if (!msg) {
                msg = @"提交失败，请重新尝试";
            }
        }
        if (msg) {
            [hud showFail:msg withDuration:DEFAULT_DISMISS_TIMEUOT];
        }
        else{
//            [hud hide:NO];
            [hud hideAnimated:YES];
        }
    }];
}
//获取指定key对应的参数
- (id) getParamFrom:(NSDictionary*)arguments forKey:(NSString *)key {
    id param = nil;
    if (key) {
        param = [arguments objectForKey:key];
        if ([param  isEqual:[NSNull null]]) {
            param = nil;
        }
    }
    return param;
}
@end
