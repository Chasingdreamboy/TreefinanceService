//
//  DSJailPlugin.h
//  gongfudaiNew
//
//  Created by EriceWang on 16/8/1.
//  Copyright © 2016年 dashu. All rights reserved.
//
#import "TBSPlugin.h"

@interface TBSJailPlugin : TBSPlugin
//获取手机是否越狱信息
- (void)check:(NSDictionary *)command;
//获取埋点中的所有paras，备用接口
- (void)params:(NSDictionary *)command;

@end
