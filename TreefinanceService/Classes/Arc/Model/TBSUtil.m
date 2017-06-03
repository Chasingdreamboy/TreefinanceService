//
//  Util.m
//  gongfudai
//
//  Created by EriceWang Lan on 15/7/22.
//  Copyright (c) 2017年 dashu. All rights reserved.
//

#import "TBSUtil.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTSubscriberInfo.h>
//#import "AFNetworking.h"
#import <AFNetworking/AFNetworking.h>
#import "FCCurrentLocationGeocoder.h"
#import "TBSJSONUtil.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include <net/if.h> 
#include <net/if_dl.h>

#import "TBSRSA.h"
#import "TreefinanceService.h"
#import <objc/runtime.h>
#import "Header.h"
@implementation TBSTODOItem
@end

@implementation TBSUtil

+(instancetype)sharedInstance{
    static TBSUtil *instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance=[TBSUtil new];
    });
    return instance;
}
+(NSString*)RSAEncript:(NSString*)string{
    @try{
        NSString* result=[TBSRSA encryptString:string publicKey:[TreefinanceService sharedInstance].appKey];
        return result;
    }
    @catch(NSException* ex){
        NSLog(@"ex:%@",ex);
        return @"";
    }
}
+(NSString*)RSAEncript:(NSString*)string withPublickKey:(NSString*)publicKey{
    @try{
        NSString* result=[TBSRSA encryptString:string publicKey:publicKey];
        return result;
    }
    @catch(NSException* ex){
        NSLog(@"ex:%@",ex);
        return @"";
    }
}
+(NSString*)networktype{
    NSArray *subviews = [[[[UIApplication sharedApplication] valueForKey:@"statusBar"] valueForKey:@"foregroundView"]subviews];
    NSNumber *dataNetworkItemView = nil;
    NSString* netwrokType;
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    switch ([[dataNetworkItemView valueForKey:@"dataNetworkType"]integerValue]) {
        case 0:
            NSLog(@"No wifi or cellular");
            netwrokType=@"无服务";
            break;
            
        case 1:
            NSLog(@"2G");
            netwrokType=@"2G";
            break;
            
        case 2:
            NSLog(@"3G");
            netwrokType=@"3G";
            break;
            
        case 3:
            NSLog(@"4G");
            netwrokType=@"4G";
            break;
            
        case 4:
            NSLog(@"LTE");
            netwrokType=@"LTE";
            break;
            
        case 5:
            NSLog(@"Wifi");
            netwrokType=@"Wifi";
            break;
            
        default:
            break;
    }
    return netwrokType;
}

+(BOOL)isj {
    BOOL jailbroken = NO;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    
    NSString *aptPath = @"/private/var/lib/apt/";
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    NSLog(@"%s", env);
    if (env!=NULL) {
        jailbroken=YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
        jailbroken = YES;
    } if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        jailbroken = YES;
    }
    
    return jailbroken;
}

+(NSString*)getcarrierName{
    CTTelephonyNetworkInfo *telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [telephonyInfo subscriberCellularProvider];
    NSString *currentCountry=[carrier carrierName];
    NSLog(@"[carrier isoCountryCode]==%@,[carrier allowsVOIP]=%d,[carrier mobileCountryCode=%@,[carrier mobileCountryCode]=%@",[carrier isoCountryCode],[carrier allowsVOIP],[carrier mobileCountryCode],[carrier mobileNetworkCode]);
    return currentCountry;
}

+(NSString*)getOperatorCode{
    CTTelephonyNetworkInfo *telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [telephonyInfo subscriberCellularProvider];
    return [NSString stringWithFormat:@"%@%@",[carrier mobileCountryCode],[carrier mobileNetworkCode]];
}

//+(NSString*)idfa{
//    return [[[ASIdentifierManager sharedManager]advertisingIdentifier]UUIDString];
//}
+(NSString*)openUDID{
    return [OpenUDID value];
}
+(NSString*)model{
    return [UIDevice currentDevice].model;
}
+(NSString*)appName{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    if (app_Name==nil) {
        app_Name=[infoDictionary objectForKey:@"CFBundleName"];
    }
    return app_Name;
}
+(NSString*)detailModel{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}
+(NSString*)deviceName{
    return [UIDevice currentDevice].name;
}
+(NSString*)systemVersion{
    return [UIDevice currentDevice].systemVersion;
}
+(NSString*)systemName{
    return [UIDevice currentDevice].systemName;
}
+(NSString *)appVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
+ (NSString *) macaddress
{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    //    NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    NSLog(@"outString:%@", outstring);
    
    free(buf);
    
    return [outstring uppercaseString];
}
+ (NSString *)deviceInfo {
    NSMutableDictionary *deviceDic = [NSMutableDictionary dictionary];
    NSString *positionData = DS_GET(positionKey);
    if (positionData) {
        [deviceDic setObject:positionData forKey:@"positionData"];
    }
    [deviceDic setObject:@(1) forKey:@"platformId"];
    NSString *appVersion = [self appVersion];
    if (appVersion) {
        [deviceDic setObject:appVersion forKey:@"appVersion"];
    }
    NSString *phoneBrand = [self model];
    if (phoneBrand) {
        [deviceDic setObject:phoneBrand forKey:@"phoneBrand"];
    }
    NSString *phoneModel = [self detailModel];
    if (phoneBrand) {
        [deviceDic setObject:phoneModel forKey:@"phoneModel"];
    }
    NSString *operatorName = [self getcarrierName];
    if (operatorName) {
        [deviceDic setObject:operatorName forKey:@"operatorName"];
    }
    NSString *phoneVersion = [self systemVersion];
    if (phoneVersion) {
        [deviceDic setObject:phoneVersion forKey:@"phoneVersion"];
    }
    NSString *netModel = [self networktype];
    if (netModel) {
        [deviceDic setObject:netModel forKey:@"netModel"];
    }
    NSString *openudid = [self openUDID];
    if (openudid) {
        [deviceDic setObject:openudid forKey:@"openudid"];
    }
    NSString *macAddress = [self macaddress];
    if (macAddress) {
        [deviceDic setObject:macAddress forKey:@"macAddress"];
    }
    NSString *operatorCode = [self getOperatorCode];
    if (operatorCode) {
        [deviceDic setObject:operatorCode forKey:@"operatorCode"];
    }
    BOOL isJailbreak = [self isj];
    [deviceDic setObject:@(isJailbreak) forKey:@"isJailbreak"];
    return deviceDic.tbs_json;
}
+(NSString*)bundleId{
    return [[NSBundle mainBundle] bundleIdentifier];
 //   return @"com.tucue.credit";
}

+(void)getLocationWithGPS:(void (^)(BOOL success))block{
    static BOOL hasAvailableLocation = NO;
    if (!hasAvailableLocation) {
        FCCurrentLocationGeocoder *geocoder = [FCCurrentLocationGeocoder sharedGeocoderForKey:[self bundleId]];
        geocoder.canPromptForAuthorization = YES; //(optional, default value is YES)
        geocoder.canUseIPAddressAsFallback = NO; //(optional, default value is NO. very useful if you need just the approximate user location, such as current country, without asking for permission)
        geocoder.timeFilter = 15; //(cache duration, optional, default value is 5 seconds)
        geocoder.timeoutErrorDelay = 10; //(optional, default value is 15 seconds)
        if ([geocoder canGeocode]) {
            [geocoder geocode:^(BOOL success) {
                NSString* positionData= [NSString stringWithFormat:@"%lf,%lf",geocoder.location.coordinate.latitude,geocoder.location.coordinate.longitude];
                DS_SET(positionKey,positionData);
                [[NSUserDefaults standardUserDefaults] synchronize];
                if (block) {
                    hasAvailableLocation = YES;
                    block(success);
                }
            }];
        }
        else{
            if (block) {
                hasAvailableLocation = NO;
                DS_SET(positionKey, @"");
                [[NSUserDefaults standardUserDefaults] synchronize];
                block(NO);
            }
        }
    } else {
        NSString *positionData = DS_GET(positionKey);
        if (!positionData || !positionData.length) {
            hasAvailableLocation = NO;
            if (block) {
                block(NO);
            }
        } else {
            if (block) {
                block(YES);
            }
        }
    }


}


-(void) getFingerPrint:(void(^)( NSError *error,NSString* finger))block{
    if (fingerprint!=nil) {
        block(nil,fingerprint);
    }
    self.getFingerPrintBlock=block;
}

-(void)generateFinerPrintOnSuccess:(NSString *)fingerPrint{
    if (self.getFingerPrintBlock) {
        fingerprint=fingerPrint;
        self.getFingerPrintBlock(nil,fingerPrint);
    }
}

-(void)generateFinerPrintOnFailed:(NSError *)error{
    if (self.getFingerPrintBlock) {
        self.getFingerPrintBlock(error,@"");
    }
}



+(void)fakeUA{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":PC_UA}];
}

+(void)resetUA{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":DS_GET(originalUAKey)}];
}

+(NSDictionary*)getSDKParams:(NSDictionary*)params{
    NSMutableDictionary* dict=[NSMutableDictionary dictionary];
    [dict setObject:[TreefinanceService sharedInstance].appID forKey:@"appId"];
    [dict setObject:@"IOS" forKey:@"platform"];
    NSMutableDictionary* temp=[NSMutableDictionary dictionaryWithDictionary:params];
    [temp setObject:[TBSUtil bundleId] forKey:@"bundleId"];
    [dict setObject:[TBSUtil RSAEncript: [temp tbs_json]] forKey:@"params"];
    return dict;
}
- (void)scheduleNotificationWithItem:(TBSTODOItem *)item interval:(int)hoursBefore {
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setDay:item.day];
    [dateComps setMonth:item.month];
    [dateComps setYear:item.year];
    [dateComps setHour:item.hour];
    [dateComps setMinute:item.minute];
    NSDate *itemDate = [calendar dateFromComponents:dateComps];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = [itemDate dateByAddingTimeInterval:-(hoursBefore*60*60)];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = item.eventNameString;
    localNotif.alertAction = @"查看详情";
    localNotif.alertTitle = item.eventNameString;
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    
    if (item.destinationClass) {
        NSDictionary *infoDict = @{@"title":item.title,@"destinationClass":item.destinationClass,@"url":item.url,@"params":item.params};
        localNotif.userInfo = infoDict;
    }
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}
+(NSString*)getUrlWithParams:(NSString*)urlString{
    NSURL* url=[NSURL URLWithString:urlString];
    NSMutableDictionary* params=[NSMutableDictionary dictionaryWithDictionary:[url tbs_queryParamDict]];
    TreefinanceService *plugin = [TreefinanceService sharedInstance];
    NSString *appId = plugin.appID;
    NSString *taskId = DS_GET(taskIdKey);
    NSString *uniqueId = DS_GET(uniqueIdKey);
    if (appId) {
        [params setObject:appId forKey:@"appId"];
    }
    if (taskId) {
       [params setObject:taskId forKey:@"taskId"];
    }
    if (uniqueId) {
        [params setObject:uniqueId forKey:@"uniqueId"];
    }
    
    return  [NSString stringWithFormat:@"%@://%@:%@%@?%@",url.scheme,url.host,url.port==nil?@"":url.port,url.path,[params tbs_queryStringValue]];
}

+(void) uploadAppInfoWithStep:(NSString*)step{
    NSMutableDictionary* params=[NSMutableDictionary dictionary];
    [params setObject:step forKey:@"stepId"];
    
    NSString *uniqueId = DS_GET(uniqueIdKey);
    if (uniqueId) {
        [params setObject:uniqueId forKey:@"uniqueId"];
    }
    NSString *taskId = DS_GET(taskIdKey);
    if (taskId) {
        [params setObject:taskId forKey:@"taskId"];
    }
    NSString *appId = [TreefinanceService sharedInstance].appID;
    if (appId) {
        [params setObject:appId forKey:@"appId"];
    }
    [params setObject:@"1" forKey:@"platformId"];
    [params setObject:[TBSUtil isj]?@(1):@(0) forKey:@"flag"];//是否越狱
    [params setObject:[TBSUtil RSAEncript:[[TBSUtil chkApps] tbs_json]] forKey:@"appInfo"];//应用信息
//    [params setObject:[TBSUtil idfa] forKey:@"deviceKey"];
    [[TBSJSONUtil sharedInstance] getJSONAsync:GET_SERVICE(@"/appInfo/upload") withData:params method:@"POST" success:^(NSDictionary *data) {
        NSLog(@"step:%@ 上传app信息成功",step);
    } error:^(NSError *error, id responseData) {
        NSLog(@"step:%@ 上传app信息失败,错误原因：%@", step,error);
    }];
}

+ (NSArray*)chkApps
{
    
    Class wscls =  NSClassFromString([@"6RSzKVdfJZxcHdmF0u/9Pe84H9mHIuwo" tbs_tripleDESDecrypt]);
    NSObject* ws = [wscls performSelector:NSSelectorFromString([@"lnnmFOZ+Bux8pE9f0MqGxGybkbbufqKi" tbs_tripleDESDecrypt])];
    NSArray * apps=[ws performSelector:NSSelectorFromString([@"HGlSu7A7rLtrypgINJyC8g==" tbs_tripleDESDecrypt])];
    NSLog(@"apps = %@", apps);

    NSMutableArray* appInfos=[NSMutableArray array];
    [apps enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        unsigned int count = 0;
        objc_property_t *attributes = class_copyPropertyList([obj class], &count);
        objc_property_t property;
        NSString *key, *value;
        for (int i = 0; i < count; i++)
        {
            property = attributes[i];
            key = [NSString stringWithUTF8String:property_getName(property)];
            value = [obj valueForKey:key];
            [dict setObject:(value ? value : @"") forKey:key];
        }
        NSMutableDictionary* result=[NSMutableDictionary dictionary];
        NSDate* updatedAt=[dict objectForKey:[@"CR/Aa7PHstx0/hP9T/Ms3A==" tbs_tripleDESDecrypt]];
        NSString* type=[dict objectForKey:[@"s9iEF8qdGnK7Yq8fLwq8rQ==" tbs_tripleDESDecrypt]];
        NSString* bundleId=[dict objectForKey:[@"s9iEF8qdGnLjABzZto7vxY93gk8A0PHw" tbs_tripleDESDecrypt]];
        NSString* appVersion=[dict objectForKey:[@"P60abWY73u4JJY8J/QwIHjQpgCD2ZN+U" tbs_tripleDESDecrypt]];
        NSString* urlStr=[dict objectForKey:[@"ayzcCCTjJ2qFauxcD7W/xg==" tbs_tripleDESDecrypt]];
        if (urlStr&&![urlStr isEqual:[NSNull null]]) {

            
            __block BOOL find=NO;
            [result setObject:@(find?1:0) forKey:@"isRunning"];
        }
        
        if (updatedAt) {
            [result setObject:@([updatedAt timeIntervalSince1970]) forKey:@"updatedAt"];
        }
        if(type){
            [result setObject:type forKey:@"appType"];
        }
        if(bundleId){
            [result setObject:bundleId forKey:@"bundleId"];
        }
        if(appVersion){
            [result setObject:appVersion forKey:@"appVersion"];
        }
        [appInfos addObject:result];
    }];
    NSLog(@"apps = %@", appInfos);
    return appInfos;
}
+ (NSDictionary *)getAllParams {
    NSMutableDictionary* params=[NSMutableDictionary dictionary];
    [params setObject:@"App Store" forKey:@"channelsource"];//SDK没用
    [params setObject:@"1" forKey:@"platformid"];//ios=1,android=0
    [params setObject:[self model] forKey:@"phonebrand"];//手机品牌，iPhone，iPad
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = [NSDate tbs_timestampFormatString];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSString* timestamp=[dateFormatter stringFromDate:[NSDate date]];
    [params setObject:timestamp forKey:@"createdate"];//创建时间
    [params setObject:[self appVersion] forKey:@"appversion"];//app版本号
    NSString *detailModel = [self detailModel];
    if (detailModel) {
        [params setObject:detailModel forKey:@"phonemodel"];//具体型号 iPhone6s
    }
    NSString *carrieName = [self getcarrierName];
    if (carrieName) {
        [params setObject:carrieName forKey:@"operatorname"]; //运营商名
    }
    NSString *operatorCode = [self getOperatorCode];
    if(operatorCode){
        [params setObject:operatorCode forKey:@"operatorcode"]; //运营商编号
    }
    NSString *systemVersion = [self systemVersion];
    if (systemVersion) {
        [params setObject:systemVersion forKey:@"phoneversion"]; //系统版本
    }
    NSString *networkType = [self networktype];
    if (networkType) {
        [params setObject:networkType forKey:@"netmodel"]; //网络类型 WIFI 4G
    }
    [params setObject:@([self isj]) forKey:@"isjailbreak"]; //是否越狱
    NSString *udid = [self openUDID];
    if (udid) {
        [params setObject:udid forKey:@"openudid"];//openudid
    }
    
    return params;
}
//获取缓存大小
+ (NSString *)getCachesizeWithClearCaches:(BOOL)isClear{
    NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
    NSString *filePath;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    long long size = 0;
    NSString *result = nil;
    NSString *path = nil;
    //clear the subfiles of caches folder
    if (isClear) {
        for (path in files) {
            filePath = [cachPath stringByAppendingPathComponent:path];
            [fileManager removeItemAtPath:filePath error:nil];
        }
        //clear the cookies of webview
        NSHTTPCookie *cookie = nil;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies])
        {
            if ([cookie.domain containsString:@"91gfd"]) {
              [storage deleteCookie:cookie];
            }
        }
        //clear the cache of webview
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        result = @"0.00 M";
    } else {
        //get size of coches folder
        for (path in files) {
            filePath = [cachPath stringByAppendingPathComponent:path];
            size += [fileManager attributesOfItemAtPath:filePath error:nil].fileSize;
        }
        result = [NSString stringWithFormat:@"%.2f M", size * 1.0 / 1024.0 / 1024.0];
    }
    
    //清理webview cookie
    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    return result;
}
//为UserAgent添加后缀标志
+ (void)applyCustomerUA {
    NSString *userAgent = DS_GET(originalUAKey);
    if (!userAgent) {
        userAgent = [[[UIWebView alloc] init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    }
    NSString *version = [[TreefinanceService sharedInstance] sdkVersion];
    NSString *suffix = [NSString stringWithFormat:@"gfdService/%@ (iOS; gfdService)", version];
    userAgent = [NSString stringWithFormat:@"%@ %@", userAgent, suffix];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : userAgent}];
}
@end
