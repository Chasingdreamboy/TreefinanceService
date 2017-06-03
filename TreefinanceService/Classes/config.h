//
//  config.h
//  gongfudai
//
//  Created by EriceWang Lan on 15/7/12.
//  Copyright (c) 2017年 dashu. All rights reserved.
//

#ifndef gongfudai_config_h
#define gongfudai_config_h

#define ISDEV NO
//#define ISDEV   [[[NSUserDefaults standardUserDefaults] objectForKey:@"enviroment"] boolValue]

//网关配置
#define SERVICE_BASE_URL    ISDEV ? @"http://gateway.test.99gfd.cn":@"https://approach.saas.treefinance.com.cn/gateway"
#define GET_SERVICE(s)  [NSString stringWithFormat:@"%@%@",SERVICE_BASE_URL,s]

//HTML5服务器地址
#define GFD_H5_BASE_URL ISDEV ? @"http://h5.saas.test.treefinance.com.cn" : @"https://approach.saas.treefinance.com.cn/h5"
#define GET_H5_URL(path) [NSString stringWithFormat:@"%@%@",GFD_H5_BASE_URL,path]

#define PC_UA               @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.130 Safari/537.36"

//超时设置（单位：秒）
#define ENTER_BACKGROUND_TIMEOUT 300

//MBProgressHud显示时间（单位：秒）
#define DEFAULT_DISMISS_TIMEUOT 2.0

#endif
