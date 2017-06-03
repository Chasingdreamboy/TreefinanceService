//
//  NSDate+Expand.m
//  gongfudai
//
//  Created by EricyWang on 14-7-26.
//  Copyright (c) 2014年 dashu. All rights reserved.
//

#import "NSDate+Expand.h"

@implementation NSDate (Expand)

+ (NSTimeInterval)tbs_timeIntervalForSince1970
{
    return [[NSDate date] timeIntervalSince1970];
}
+ (NSString *)tbs_timestampFormatString {
    return @"yyyy-MM-dd HH:mm:ss";
}
@end
