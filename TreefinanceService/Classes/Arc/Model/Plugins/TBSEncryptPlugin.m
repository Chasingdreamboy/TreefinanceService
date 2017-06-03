//
//  DSEncryptPlugin.m
//  GFDSDK
//
//  Created by EriceWang on 16/6/1.
//  Copyright © 2016年 Hangzhou Tree Finance Ltd. All rights reserved.
//

#import "TBSEncryptPlugin.h"
#import "TBSJSONUtil.h"

#import "Header.h"
@implementation TBSEncryptPlugin

- (void)encrypt:(NSDictionary *)command {
    NSDictionary *orignalDic = [command objectForKey:@"params"];
    if ([orignalDic isKindOfClass:[NSString class]]) {
        orignalDic = [(NSString *)orignalDic tbs_getSetFromJson];
    }
    
    NSDictionary *encryptedDic = orignalDic.tbs_getParasWithEncrypt;
    
    if (encryptedDic) {
        [self sendResult:command code:DSOperationStateSuccess result:encryptedDic];
    } else {
        [self sendResult:command code:DSOperationStateUnknownError result:nil];
    }
    
}
@end
