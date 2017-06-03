//
//  ServicePlugin.h
//
//  Created by EriceWang Lan on 15/11/9.
//  Copyright (c) 2017年 Hangzhou Tree Finance Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^_Nullable CallBackExecute)(NSInteger resultStatus, NSString* _Nullable taskId, NSString * _Nullable uniqueId, NSString * _Nullable params);
typedef NS_ENUM(NSInteger, DSWebLoginType) {
    DSWebLoginTypeEmail,
    DSWebLoginTypeOperater,
    DSWebLoginTypeEcommerce
    
};
@interface TreefinanceService: NSObject

@property(nonatomic,readonly)  NSString *_Nonnull  appID;
@property(nonatomic,readonly) NSString *_Nonnull appKey;
@property(nonatomic,readonly) NSString *_Nonnull sdkVersion;

/*
 * 1. 初始化方法获取单例对象
 */
+(_Nonnull instancetype)sharedInstance;
/*
 * 2. 设置appID和appKey
 */
-(void)setupAPPID:(NSString*_Nonnull)appID appKey:(NSString*_Nonnull)appKey;

/*
 3.启动sdk
 uniqueId:任务标志id
 latitude:纬度(地理位置坐标)
 longtitude:经度(地理位置坐标)
 coorType:地理位置坐标系
 appendParameters:回调参数
 type:操作类型
 
 其中:
 coorType 有三种常用类型
 coorType
 bd09ll
 gcj02ll
 wgs84ll
 默认使用 wgs84ll
 
 type支持三种类型：
 DSWebLoginTypeEmail,//邮箱
 DSWebLoginTypeOperater,//运营商
 DSWebLoginTypeEcommerce//电商
*/

/**
 use this method to start service.
 @param uniqueId uniqueId for task (@required)
 @param latitude latitude of the user's position (@optional)
 @param longtitude longtitude of user's position (@optional)
 @param coorType coordinate system type (@optional)
 @param parameters some exter parameters for jump link
 @param type the type for operation
 @param extra reserved parameters, default to nil.
 @para callback  
 */
- (void)start:(nonnull NSString *)uniqueId latitude:(NSString *_Nullable)latitude longtitude:(NSString *_Nullable)longtitude coorType:(NSString *_Nullable) coorType appendParameters:(NSDictionary *_Nullable)parameters type:(DSWebLoginType) type extra:(NSDictionary *_Nullable)extra callback:(CallBackExecute)callback;
@end
