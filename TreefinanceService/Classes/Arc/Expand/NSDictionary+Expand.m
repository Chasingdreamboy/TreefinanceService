//
//  NSDictionary+Expand.m
//  gongfudai
//
//  Created by EriceWang Lan on 15/8/14.
//  Copyright (c) 2017年 dashu. All rights reserved.
//

#import "NSDictionary+Expand.h"
#import "TBSUtil.h"
#import "NSArray+Expand.h"
#import "TreefinanceService.h"
#import "Header.h"

@implementation NSDictionary(Expand)
-(NSString *)tbs_json{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    if (! jsonData) {
        NSLog(@"json转换失败: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
- (NSDictionary *)tbs_getParasWithEncrypt {
    NSString *appId = [TreefinanceService sharedInstance].appID;
    if (!appId ||[appId isEqual:[NSNull null]]|| !appId.length) {
        DSLog(@"appId参数不合法!!!appId = %@", appId);
        return nil;
    }
    NSMutableDictionary* dict=[NSMutableDictionary dictionary];
    [dict setObject:appId forKey:@"appid"];
    [dict setObject:@"IOS" forKey:@"platform"];
    NSString* jsonParams=[[self getApppendedParams:self] tbs_json];
    [dict setObject:[TBSUtil RSAEncript:jsonParams] forKey:@"params"];
    return dict;
}
- (NSDictionary *)tbs_getParasWithoutEncript {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self getApppendedParams:self]];
    return (NSDictionary *)dic;
}
//自动加上常带的请求参数
-(NSDictionary*)getApppendedParams:(NSDictionary*)params{
    NSMutableDictionary* dict=[NSMutableDictionary dictionary];
    NSString *token = [NSString stringWithFormat:@"%@", DS_GET(@"ds_token")];
    if (token) {
        [dict setObject:token forKey:@"token"];
    }
    //V1.0.3新加参数----
    NSString *appVersion = [TBSUtil appVersion];
    if (appVersion) {
        [dict setObject:appVersion forKey:@"appVersion"];
    }
    NSString *detailModel = [TBSUtil detailModel];
    if (detailModel) {
        [dict setObject:detailModel forKey:@"model"];
    }
    NSString *carrieName = [TBSUtil getcarrierName];
    if (carrieName) {
        [dict setObject:carrieName forKey:@"operatorName"];
    }
    NSString *systemVersion = [TBSUtil systemVersion];
    if (systemVersion) {
        [dict setObject:systemVersion forKey:@"systemVersion"];
    }
    NSString *networkType = [TBSUtil networktype];
    if (networkType) {
        [dict setObject:networkType forKey:@"networkType"];
    }
    NSString *bundleId = [TBSUtil bundleId];
    if(bundleId){
        [dict setObject:bundleId forKey:@"bundleId"];
    }
    //-----------------
    //V1.0.5 新加参数;
    [dict setObject:@"ios" forKey:@"platform"];
    //--------------
    if (params) {
        [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isKindOfClass:[NSArray class]]||[obj isKindOfClass:[NSMutableArray class]]) {
                [dict setObject:[(NSArray*)obj tbs_json] forKey:key];
            }
            else if ([obj isKindOfClass:[NSDictionary class]]||[obj isKindOfClass:[NSMutableDictionary class]]) {
                [dict setObject:[(NSDictionary*)obj tbs_json] forKey:key];
            }
            else{
                [dict setObject:obj forKey:key];
            }
        }];
    }
    return dict;
}
@end
