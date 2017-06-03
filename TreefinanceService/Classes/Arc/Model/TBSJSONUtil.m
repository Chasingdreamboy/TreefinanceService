//
//  DSJSONUtil.m
//  gongfudai
//
//  Created by EriceWang Lan on 15/7/24.
//  Copyright (c) 2017年 dashu. All rights reserved.
//

#import "TBSJSONUtil.h"
//#import "AFNetworking.h"
#import <AFNetworking/AFNetworking.h>
#import <objc/message.h>
#import "TreefinanceService.h"
#import "TBSUtil.h"
#import "UIAlertView+Expand.h"
#import "Header.h"

static TBSJSONUtil* util;
static NSTimeInterval defaultTimeOut=30.0;
static NSTimeInterval defaultSyncTimeOut=4.0;
typedef void (^SuccessBlock)(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject);
typedef void(^ProgressBlock)(NSProgress * _Nonnull uploadProgress);
typedef void (^FailBlock)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error);

@implementation TBSJSONUtil

+(instancetype)sharedInstance{
    if (util==nil) {
        util=[[self alloc]init];
    }
    return util;
}

-(instancetype)init{
    self=[super init];
    alert=[[RKDropdownAlert alloc]initWithFrame:CGRectMake(0, -90, [[UIScreen mainScreen]bounds].size.width, 90)];
    alertView=[[UIAlertView alloc]initWithTitle:@"提示" message:@"您的账户登录超时或已在别处登录" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
    return self;
}

-(NSDictionary*)getJSON:(NSString*)url withData:(NSDictionary*)params method:(NSString*)method error:(NSError *__autoreleasing *)error{
    __block NSDictionary *responseObject = nil;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);//创建一个信号量
    url = [NSString stringWithFormat:@"%@?%@", url, params.tbs_queryStringValue];
    NSURL *URL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:method];
    [request setTimeoutInterval:defaultTimeOut];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *jsonError = nil;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        if (jsonError || !dic || error) {
            responseObject = nil;
            error = jsonError ? : error;
            if (error) {
                NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
                if (res.statusCode == 401) {
                    [self logout];
                } else if (!data){
                    [self dealWithServerError];
                }
            }
        } else {
            responseObject = dic;
            error = nil;
        }
        dispatch_semaphore_signal(sem);
    }];
    [task resume];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return responseObject;
}

-(void)getJSONAsync:(NSString*)url withData:(NSDictionary*)params method:(NSString*)method success:(void (^)(NSDictionary* data))success error:(void (^)(NSError* error,id responseData))fail{
    NSString *requestMethod = [method uppercaseString];
    SuccessBlock successBlock = ^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject){
        if (success) {
            success(responseObject);
        }
    };
    FailBlock failBlock = ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        
        if (fail) {
            if (httpResponse.statusCode == 401) {
                [self logout];
            } else if (httpResponse.statusCode == 500) {
                [self dealWithServerError];
            } else {
                //服务器返回的业务逻辑报文信息
                NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                NSDictionary *responseObject  = (NSDictionary *)errResponse.tbs_getSetFromJson;
                if ([responseObject isKindOfClass:[NSString class]]) {
                    if (error.code == -1001 ) {
                        responseObject = @{@"errorMsg":@"网络异常，请检测网络连接！"};
                    } else {
                        responseObject = @{@"errorMsg":@"内部错误，请稍后重试！"};
                    }
                }
                fail(error, responseObject);
            }
        }
    };
    NSString *selString = [NSString stringWithFormat:@"%@:parameters:progress:success:failure:", requestMethod];
    SEL sel = NSSelectorFromString(selString);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:defaultSyncTimeOut];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",nil];
    NSMutableDictionary* result=[NSMutableDictionary dictionary];
    if (params) {
        [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isKindOfClass:[NSArray class]]||[obj isKindOfClass:[NSMutableArray class]]) {
                [result setObject:[(NSArray*)obj tbs_json] forKey:key];
            }
            else if ([obj isKindOfClass:[NSDictionary class]]||[obj isKindOfClass:[NSMutableDictionary class]]) {
                [result setObject:[(NSDictionary*)obj tbs_json] forKey:key];
            }
            else{
                [result setObject:obj forKey:key];
            }
        }];
    }
    
    ((void(*)(id,SEL,NSString*, NSDictionary*,ProgressBlock,SuccessBlock, FailBlock))objc_msgSend)(manager,sel,url, result, nil,successBlock, failBlock);
}


-(void)getJSONAsyncQuietlyWithOutDefaultParams:(NSString*)url withData:(NSDictionary*)params method:(NSString*)method success:(void (^)(NSDictionary* data))success error:(void (^)(NSError* error,id responseData))fail{
    NSString *requestMethod = [method uppercaseString];
    SuccessBlock successBlock = ^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject){
        if (success) {
            success(responseObject);
        }
    };
    FailBlock failBlock = ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if (fail) {
            if (httpResponse.statusCode == 401) {
                [self logout];
            } else if (httpResponse.statusCode == 500) {
                [self dealWithServerError];
            } else {
                //服务器返回的业务逻辑报文信息
                NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                NSDictionary *responseObject  = (NSDictionary *)errResponse.tbs_getSetFromJson;
                if ([responseObject isKindOfClass:[NSString class]]) {
                    if (error.code == -1001 ) {
                        responseObject = @{@"errorMsg":@"网络异常，请检测网络连接！"};
                    } else {
                        responseObject = @{@"errorMsg":@"内部错误，请稍后重试！"};
                    }
                }
                fail(error, responseObject);
            }
        }
    };
    NSString *selString = [NSString stringWithFormat:@"%@:parameters:progress:success:failure:", requestMethod];
    SEL sel = NSSelectorFromString(selString);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:defaultSyncTimeOut];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/javascript",nil];
    NSMutableDictionary* result=[NSMutableDictionary dictionary];
    if (params) {
        [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isKindOfClass:[NSArray class]]||[obj isKindOfClass:[NSMutableArray class]]) {
                [result setObject:[(NSArray*)obj tbs_json] forKey:key];
            }
            else if ([obj isKindOfClass:[NSDictionary class]]||[obj isKindOfClass:[NSMutableDictionary class]]) {
                [result setObject:[(NSDictionary*)obj tbs_json] forKey:key];
            }
            else{
                [result setObject:obj forKey:key];
            }
        }];
    }
    
    ((void(*)(id,SEL,NSString*, NSDictionary*,ProgressBlock,SuccessBlock, FailBlock))objc_msgSend)(manager,sel,url, result, nil,successBlock, failBlock);
}

- (void)sendError:(NSDictionary *)exception callback:(void(^)(BOOL success, id extra))callback{
    NSMutableDictionary *paras = [TBSUtil getAllParams].mutableCopy;
    for (NSString *key in exception.allKeys) {
        [paras setObject:exception[key] forKey:key];
    }
    NSString *json = paras.tbs_json;
    [[TBSJSONUtil sharedInstance] getJSONAsync:GET_SERVICE(@"/appLog/error") withData:@{@"log" : json} method:@"POST" success:^(NSDictionary *data) {
        if (callback) {
            callback(YES, nil);
        }
    } error:^(NSError *error, id responseData) {
        if (callback) {
            
            callback(NO, error);
        }
    }];
}
-(void)logout{
    if (![alertView isVisible]) {
        [alertView tbs_showAlertViewWithCompleteBlock:^(NSInteger buttonIndex, UIAlertView *alertView) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"logout" object:nil];
        }];
    }
}



-(void)dealWithServerError{
    UIColor *bgColor = [UIColor tbs_colorWithHexString:@"F55C23" alpha:1.0];
    UIColor *textColor = [UIColor tbs_colorWithHexString:@"FFFFFF" alpha:1.0];
    [alert title:@"发生错误" message:@"服务器内部错误，请稍后重试!" backgroundColor:bgColor textColor:textColor time:3.0];
}

-(id)getParam:(NSString*)name fromDict:(NSDictionary*)param{
    if (param==nil||name==nil) {
        return nil;
    }
    if ([name containsString:@"."]) {
        NSArray* splitedParams=[name componentsSeparatedByString:@"."];
        id tempObj=param;
        for (NSInteger i=0,n=splitedParams.count; i<n; ++i) {
            tempObj=[tempObj objectForKey:[splitedParams objectAtIndex:i]];
            if (tempObj==nil||i==n) {
                break;
            }
        }
        return tempObj;
    }
    else{
        return [param objectForKey:name];
    }
}
@end
