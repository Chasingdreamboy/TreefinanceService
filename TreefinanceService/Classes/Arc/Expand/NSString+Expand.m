//
//  NSString+Expand.m
//  gongfudai
//
//  Created by _tauCross on 14-7-16.
//  Copyright (c) 2014年 dashu. All rights reserved.
//

#import "NSString+Expand.h"
#import "TBSGTMBase64.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation NSString (Expand)
-(BOOL) tbs_isMobilePhone{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9]{11}$"];
    return [predicate evaluateWithObject:self];
}

-(BOOL) tbs_isValidPassword{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9A-Za-z]*$"];
    return self!=nil&&[predicate evaluateWithObject:self]&&self.length>=6&&self.length<=18;
}


-(NSString *)tbs_tripleDESEncrypt
{
    return [self tbs_tripleDESEncryptWithKey:DESKEY];
}

-(NSString *)tbs_tripleDESDecrypt
{
     return [self tbs_tripleDESDecryptWithKey:DESKEY];
}
- (NSString *)tbs_tripleDESDecryptWithKey:(NSString *)key
{
    return [self tbs_tripleDESEncryptOrDecrypt:kCCDecrypt isSpecial:NO key:key];
}
//
- (NSString *)tbs_tripleDESEncryptWithKey:(NSString *)key
{
    return [self tbs_tripleDESEncryptOrDecrypt:kCCEncrypt isSpecial:NO key:key];
}

-(NSString*)tbs_tripleDESEncryptOrDecrypt:(CCOperation)encryptOrDecrypt isSpecial:(BOOL)aIsSpecial key:(NSString *)key
{
    

    const void *vplainText;
    size_t plainTextBufferSize;
    
    if (encryptOrDecrypt == kCCDecrypt)//解密
    {
        NSData *EncryptData = [TBSGTMBase64 decodeData:[self dataUsingEncoding:NSUTF8StringEncoding]];
        plainTextBufferSize = [EncryptData length];
        vplainText = [EncryptData bytes];
    }
    else //加密
    {
        NSData* data = [self dataUsingEncoding:NSUTF8StringEncoding];
        plainTextBufferSize = [data length];
        vplainText = (const void *)[data bytes];
    }
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *)[key cStringUsingEncoding:NSASCIIStringEncoding];

    ccStatus = CCCrypt(encryptOrDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding | kCCOptionECBMode,
                       vkey,
                       kCCKeySize3DES,
                       nil,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes); 
    
    NSString *result;
    
    if (encryptOrDecrypt == kCCDecrypt)
    {
        NSData *data =  [NSData dataWithBytes:(const void *)bufferPtr
                                       length:(NSUInteger)movedBytes];
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    else
    {
        NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
        if(!aIsSpecial)
        {
            result = [TBSGTMBase64 stringByEncodingData:myData];
        }
        else
        {
            NSString *myStr = [myData description];
            if([myStr hasPrefix:@"<"] && [myStr hasSuffix:@">"])
            {
                myStr = [myStr substringWithRange:NSMakeRange(1, [myStr length]-2)];
                result = [myStr stringByReplacingOccurrencesOfString:@" " withString:@""];
            }
            else
            {
                result = nil;
            }
        }
    }
    
    free(bufferPtr);
    
    return result;
}
- (NSString *)tbs_deleteMoreWhitespaceAndNewlineCharacter {
    NSString *result = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *components = [result componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];
    result = [components componentsJoinedByString:@""];//按单空格分割
    result = [result stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return result;
}
- (id)tbs_getSetFromJson {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id set = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error && error.code == 3840) {
        //本身就是字符串
        set = self;
    } else if (error) {
        set = nil;
    }
    return set;
}



@end
