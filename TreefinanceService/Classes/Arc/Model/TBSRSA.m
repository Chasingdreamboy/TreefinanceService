//
//  RSA.m
//  My
//
//  Created by ideawu on 15-2-3.
//  Copyright (c) 2017年 ideawu. All rights reserved.
//

#import "TBSRSA.h"
#import <Security/Security.h>
#import "TBSGTMBase64.h"
#import "Header.h"
@implementation TBSRSA


static NSString *base64_encode_data(NSData *data){
    return [TBSGTMBase64 stringByEncodingData:data];
}

static NSData *base64_decode(NSString *str){
    return [TBSGTMBase64 decodeString:str];
}

+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey{
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return [TBSRSA encryptData:data publicKey:pubKey];
}

+ (NSString *)encryptInteger:(NSInteger)integer publicKey:(NSString *)pubKey{
    NSString * str = [NSString stringWithFormat:@"%li",(long)integer];
    return [TBSRSA encryptString:str publicKey:pubKey];
}

+ (NSString *)encryptCGFloat:(CGFloat)cgFloat publicKey:(NSString *)pubKey{
    NSString * str = [NSString stringWithFormat:@"%f",cgFloat];
    return [TBSRSA encryptString:str publicKey:pubKey];
}

+ (NSString *)encryptDouble:(double)doubleValue publicKey:(NSString *)pubKey{
    NSString * str = [NSString stringWithFormat:@"%f",doubleValue];
    return [TBSRSA encryptString:str publicKey:pubKey];
}

+ (NSString *)encryptData:(NSData *)data publicKey:(NSString *)pubKey{
    if(!data || !pubKey || [pubKey isEqual:[NSNull null]]){
        return nil;
    }
    SecKeyRef keyRef = [TBSRSA addPublicKey:pubKey];
    if (!keyRef) {
        NSLog(@"PUBLIC KEY IS NIL");
        return nil;
    }
    size_t cipherBufferSize = SecKeyGetBlockSize(keyRef);
    
    uint8_t *cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    NSData *stringBytes = data;
    size_t blockSize = cipherBufferSize - 11;
    size_t blockCount = (size_t)ceil([stringBytes length] / (double)blockSize);
    NSMutableData *encryptedData = [[NSMutableData alloc] init];
    for (int i=0; i<blockCount; i++) {
        int bufferSize = (int)MIN(blockSize,[stringBytes length] - i * blockSize);
        NSData *buffer = [stringBytes subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        OSStatus status = SecKeyEncrypt(keyRef, kSecPaddingPKCS1, (const uint8_t *)[buffer bytes],
                                        [buffer length], cipherBuffer, &cipherBufferSize);
        if (status == noErr){
            NSData *encryptedBytes = [[NSData alloc] initWithBytes:(const void *)cipherBuffer length:cipherBufferSize];
            [encryptedData appendData:encryptedBytes];
        }else{
            if (cipherBuffer) free(cipherBuffer);
            return nil;
        }
    }
    if (cipherBuffer) free(cipherBuffer);
    //  NSLog(@"Encrypted text (%d bytes): %@", [encryptedData length], [encryptedData description]);
    //  NSLog(@"Encrypted text base64: %@", [Base64 encode:encryptedData]);
//    return encryptedData;
   
    NSString* ret = base64_encode_data(encryptedData);
    CFRelease(keyRef);
    return ret;
}

+ (SecKeyRef)addPublicKey:(NSString *)key{
//	NSRange spos = [key rangeOfString:@"-----BEGIN PUBLIC KEY-----"];
//	NSRange epos = [key rangeOfString:@"-----END PUBLIC KEY-----"];
//	if(spos.location != NSNotFound && epos.location != NSNotFound){
//		NSUInteger s = spos.location + spos.length;
//		NSUInteger e = epos.location;
//		NSRange range = NSMakeRange(s, e-s);
//		key = [key substringWithRange:range];
//	}
	key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
	key = [key stringByReplacingOccurrencesOfString:@" "  withString:@""];
	
	// This will be base64 encoded, decode it.
	NSData *data = base64_decode(key);
	data = [TBSRSA stripPublicKeyHeader:data];
	if(!data){
        NSLog(@"stripPublicKeyHeader nil");
		return nil;
	}
	
	NSString *tag = @"what_the_fuck_is_this";
	NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
	
	// Delete any old lingering key with the same tag
	NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
	[publicKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
	[publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
	[publicKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
	SecItemDelete((__bridge CFDictionaryRef)publicKey);
	
	// Add persistent version of the key to system keychain
	[publicKey setObject:data forKey:(__bridge id)kSecValueData];
	[publicKey setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id)
	 kSecAttrKeyClass];
	[publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)
	 kSecReturnPersistentRef];
	
	CFTypeRef persistKey = nil;
	OSStatus status = SecItemAdd((__bridge CFDictionaryRef)publicKey, &persistKey);
	if (persistKey != nil){
		CFRelease(persistKey);
	}
	if ((status != noErr) && (status != errSecDuplicateItem)) {
        NSLog(@"wtf1 nil,%d",(int)status);
		return nil;
	}

	[publicKey removeObjectForKey:(__bridge id)kSecValueData];
	[publicKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
	[publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
	[publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
	
	// Now fetch the SecKeyRef version of the key
	SecKeyRef keyRef = nil;
	status = SecItemCopyMatching((__bridge CFDictionaryRef)publicKey, (CFTypeRef *)&keyRef);
	if(status != noErr){
        NSLog(@"wtf2 nil,%d",(int)status);
		return nil;
	}
	return keyRef;
}

+ (NSData *)stripPublicKeyHeader:(NSData *)d_key{
    // Skip ASN.1 public key header
    if (d_key == nil) return(nil);
    
    unsigned long len = [d_key length];
    if (!len) return(nil);
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx    = 0;
    
    if (c_key[idx++] != 0x30) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
    { 0x30,   0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
        0x01, 0x05, 0x00 };
    if (memcmp(&c_key[idx], seqiod, 15)) return(nil);
    
    idx += 15;
    
    if (c_key[idx++] != 0x03) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    if (c_key[idx++] != '\0') return(nil);
    
    // Now make a new NSData from this buffer
    return([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

@end
