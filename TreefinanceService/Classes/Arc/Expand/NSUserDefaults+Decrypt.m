//
//  NSUserDefaults+Decrypt.m
//  kaixindai
//
//  Created by EriceWang on 2017/3/4.
//  Copyright © 2017年 Ericdong. All rights reserved.
//

#import "NSUserDefaults+Decrypt.h"
#import "NSString+Expand.h"
//#import "NSObject+Expand.h"
#import "NSArray+Expand.h"

@implementation NSUserDefaults (Decrypt)

- (id)tbs_objectForKey:(NSString *)defaultName {
    NSString *encryptName = [defaultName tbs_tripleDESEncrypt];
    NSString *result = (NSString *)[self objectForKey:encryptName];
    result = [result tbs_tripleDESDecrypt];
    id value = [(NSArray *)result.tbs_getSetFromJson firstObject];
    if ([value isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@", value];
    } else {
        return value;
    }
}
- (void)tbs_setObject:(id)value forKey:(NSString *)defaultName {
    NSString *encryptName = [defaultName tbs_tripleDESEncrypt];
    if (encryptName && !value) {
        [self removeObjectForKey:encryptName];
        return;
    } else {
        NSString *result = [self getJSONFromSet:value];
        result = [result tbs_tripleDESEncrypt];
        [self setObject:result forKey:encryptName];
    }

    [self synchronize];
}
- (NSString *)getJSONFromSet:(id)value {
    id arguments = (value == nil ? [NSNull null] : value);
    NSArray* argumentsWrappedInArray = @[arguments];
    NSString* argumentsJSON = argumentsWrappedInArray.tbs_json;
    return argumentsJSON;
}
@end
