//
//  ConstString.h
//  jidongsudai
//
//  Created by EriceWang on 16/8/26.
//  Copyright © 2016年 dashu. All rights reserved.
//

#ifndef ConstString_h
#define ConstString_h
//本地化数据存储字符串(加密)
//static NSString *userIdKey     = @"userId";//用户id
//static NSString *tokenKey      = @"token";//用户token信息
//static NSString *mobileKey     = @"mobile";//电话号存储
static NSString *positionKey   = @"positionData";//用户地理位置信息
static NSString *taskIdKey     = @"taskId";
static NSString *uniqueIdKey      = @"uniqueId";
static NSString *paramsKey        = @"params";
static NSString *colorsKey        = @"color";
static NSString *btnColorKey        = @"btnColor";

//static NSString *operationTypeKey       =  @"operationType";
static NSString *coorTypekey            =  @"coorType";
static NSString *appendParametersKey       = @"appendParameters";
static NSString *webLoginTypeKey              = @"webLoginType";
static NSString *tintColorKey              = @"tintColor";
static NSString *backgroundColorKey    = @"backgroundColor";


//本地化数据存储字符串(未加密)
static NSString *appVersionKey      = @"appVersion";//app版本
static NSString *originalUAKey      = @"originalUA";
static NSString *schemeUrlKey       = @"schemeUrl";//回调需要打开的detinationClass
static NSString *isLogedInKey       = @"logedIn";
static NSString *lastInactiveTimeKey   = @"LastInactiveTime";//最后一次进入后台运行时的时间戳
static NSString *lastGetLocationTimestampKey = @"lastGetLocationTimestamp";
static NSString *queryStringKey = @"queryString";

#endif /* ConstString_h */
