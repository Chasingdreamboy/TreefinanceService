//
//  NSArray+Expand.m
//  gongfudai
//
//  Created by EriceWang Lan on 15/7/29.
//  Copyright (c) 2017年 dashu. All rights reserved.
//

#import "NSArray+Expand.h"

@implementation NSArray(Expand)
- (NSString*)tbs_json
{
    NSString* json = nil;
    NSError* error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return (error ? nil : json);
}

@end
