//
//  GFDAppConfig.m
//  gongfudai
//
//  Created by EricyWang on 15/11/18.
//  Copyright © 2015年 dashu. All rights reserved.
//

#import "TBSConfigPlugin.h"
#import "Header.h"

@implementation TBSConfigPlugin
-(void)load:(NSDictionary*)command {
    NSMutableDictionary* config = [[NSMutableDictionary alloc] init];
    NSString* bizGatewayUrl = SERVICE_BASE_URL;
    NSString* pageUrl =  GFD_H5_BASE_URL;
    if (![bizGatewayUrl hasSuffix:@"/"]) {
        bizGatewayUrl = [bizGatewayUrl stringByAppendingString:@"/"];
    }
    if (![pageUrl hasSuffix:@"/"]) {
        pageUrl = [pageUrl stringByAppendingString:@"/"];
    }
    
//    [config setValue:userId forKey:@"user_id"];
//    [config setValue:token forKey:@"token"];
    [config setValue:bizGatewayUrl forKey:@"biz_gateway_url"];
    [config setValue:pageUrl forKey:@"page_url"];
    [self sendResult:command code:DSOperationStateSuccess result:config];
}

-(void)get:(NSDictionary *)command {
    NSString* key = [command objectForKey:@"key"];
    NSString* value = @"";
    if (key) {
        value = DS_GET(key);
    }
    [self sendResult:command code:DSOperationStateSuccess result:value];
}
-(void)set:(NSDictionary *)command {
    NSString* key = [command objectForKey:@"key"];
    NSObject* value = [command objectForKey:@"value"];

    if (key&&value) {
        DS_SET(key, value);
        [self sendResult:command code:DSOperationStateSuccess result:nil];
    } else {
        [self sendResult:command code:DSOperationStateParamsError result:nil];
    }
}

@end
