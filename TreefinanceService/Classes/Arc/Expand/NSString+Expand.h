//
//  NSString+Expand.h
//  gongfudai
//
//  Created by _tauCross on 14-7-16.
//  Copyright (c) 2014年 dashu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSGTMBase64.h"

#define kChosenDigestLength		CC_SHA1_DIGEST_LENGTH
#define DESKEY @"dashu123fuck51hehe"


@interface NSString (Expand)

- (NSString *)tbs_tripleDESEncrypt;//标准3DES+Base64加密
- (NSString *)tbs_tripleDESDecrypt;//标准3DES+Base64解密

- (NSString *)tbs_tripleDESEncryptWithKey:(NSString *)key;
- (NSString *)tbs_tripleDESDecryptWithKey:(NSString *)key;

-(BOOL) tbs_isMobilePhone;

-(BOOL) tbs_isValidPassword;

- (NSString *)tbs_deleteMoreWhitespaceAndNewlineCharacter;
- (id)tbs_getSetFromJson;


@end
