//
//  Util.h
//  gongfudai
//
//  Created by EriceWang Lan on 15/7/22.
//  Copyright (c) 2017年 dashu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AdSupport/AdSupport.h>
#import <OpenUDID/OpenUDID.h>
#import <CoreLocation/CoreLocation.h>
//#import "FMDeviceManager.h"

@interface TBSTODOItem : NSObject
@property(nonatomic) NSInteger day;
@property(nonatomic) NSInteger month;
@property(nonatomic) NSInteger year;
@property(nonatomic) NSInteger hour;
@property(nonatomic) NSInteger minute;
@property(nonatomic,copy) NSString* eventNameString;
@property(nonatomic,copy) NSString* title;
@property(nonatomic,copy) NSString* destinationClass;
@property(nonatomic,copy) NSString* url;
@property(nonatomic,copy) NSDictionary* params;
@end

@interface TBSUtil : NSObject
{
    @private
    NSString* fingerprint;
}
@property(nonatomic,copy) void (^(getFingerPrintBlock))(NSError*,NSString*);
+(NSString*)networktype;
+(NSString*)getcarrierName;
//+(NSString*)idfa;
+(NSString*)openUDID;
+(NSString*)model;
+(NSString*)detailModel;
+(NSString*)bundleId;
+(NSString*)deviceName;
+(NSString*)systemVersion;
+(NSString*)systemName;
+(NSString*)appName;
+(NSString*)appVersion;
+ (NSString *)deviceInfo;
+(NSString*)RSAEncript:(NSString*)string;
+(NSString*)RSAEncript:(NSString*)string withPublickKey:(NSString*)publicKey;
+(NSString*)getUrlWithParams:(NSString*)urlString;
+(void)uploadAppInfoWithStep:(NSString*)step;
+(BOOL)isj;
+(void)fakeUA;//使用PC Useragent
+(void)resetUA;//重置useragent
//+(void)blackboxWithStep:(NSString*)step;//同盾埋点
+(void)getLocationWithGPS:(void (^)(BOOL success))block;//获取地理位置
+ (NSArray*)chkApps;
+ (NSDictionary *)getAllParams;
+ (NSString *)getCachesizeWithClearCaches:(BOOL)isClear;
+ (void)applyCustomerUA;
@end
