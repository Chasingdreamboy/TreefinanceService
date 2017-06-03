//
//  macro.h
//  gongfudai
//
//  Created by EriceWang Lan on 15/6/18.
//  Copyright (c) 2017年 dashu. All rights reserved.
//

#ifndef gongfudai_macro_h
#define gongfudai_macro_h
#import <UIKit/UIKit.h>
#import "NSUserDefaults+Decrypt.h"

//密钥
#define PUBLIC_KEY          @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDFweUCcbpWo1e1D86ELyDwmsW2PHOqdbc0av/wyPs8mfxckfWb9+CIVaeCUB44cBcNEMQZ/0uuKOL07XytWReO9rIerOIdw6dUKfnd6j6YiB6J2N1/K50clYKunLUeUjI/ATJqi4l4B4T15swbfQwSvssXWKLImevBSvJmxrvIJwIDAQAB"

//version
#define IOS_VERSION         [[UIDevice currentDevice] systemVersion]
#define IOS_OR_LATER(s)       ([[[UIDevice currentDevice] systemVersion] compare:[NSString stringWithFormat:@"%@", @(s)] options:NSNumericSearch] != NSOrderedAscending)

//device
#define SCREEN_BOUNDS       ([UIScreen mainScreen].bounds)
#define SCREEN_HEIGHT       ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_WIDTH        ([UIScreen mainScreen].bounds.size.width)
#define IS_568              (SCREEN_HEIGHT == 568)
#define IS_iPad             (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IS_Iphone4          (SCREEN_HEIGHT == 480)
#define IS_Iphone5          (SCREEN_HEIGHT == 568)
#define IS_Iphone6          (SCREEN_HEIGHT == 667)
//#define IS_Iphone6p          (SCREEN_HEIGHT == 736)
#define IS_Iphone6p_Or_Later (SCREEN_HEIGHT >= 736)
#define DSMAX(a,b)            a>b?a:b
#define DSMIN(a,b)            a<b?a:b

#define ScaleFrom_iPhone5_Desgin(_X_) (_X_ * (SCREEN_WIDTH/320))
#define ScaleFrom_iPhone6_Desgin(_X_) (_X_ * (SCREEN_WIDTH/375))

//COLOR
#define DS_CClear               [UIColor clearColor]
#define DS_CRGB(r,g,b,a)        [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define DS_CHex(rgbValue)       [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define DS_F(fontName,fontSize) [UIFont fontWithName:fontName size:fontSize]


#define RGBCOLOR(r,g,b)                     [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a)                  [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define GETVALUE(key)   [[NSBundle mainBundle] objectForInfoDictionaryKey:key]
//工具方法
#define DS_GET(k)           [[NSUserDefaults standardUserDefaults] tbs_objectForKey:k]
#define DS_SET(k,v)         [[NSUserDefaults standardUserDefaults] tbs_setObject:v forKey:k]
#define TBS_BUNDLE   [TBSHelper bundle]

#define DS_STR_FORMAT(a,b)       [NSString stringWithFormat:a,b]


//#define NSLog(format,...) nil;
#if DEBUG
#define DSLog(format,...) fprintf(stderr,"\nfunction:%s line:%d content:%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String])
#else
#define DSLog(format,...)  nil
#endif


#endif




