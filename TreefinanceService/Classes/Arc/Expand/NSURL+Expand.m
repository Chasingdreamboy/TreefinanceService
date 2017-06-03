//
//  NSURL+Expand.m
//  gongfudai
//
//  Created by Jay Ni on 15/3/11.
//  Copyright (c) 2017年 Hangzhou dashu Tech Ltd. All rights reserved.
//

#import "NSURL+Expand.h"

@implementation NSURL (Expand)

-(NSDictionary *)tbs_queryParamDict{
    NSString *queryString = self.query;
    if(!self.query || self.query.length == 0){
        return nil;
    }
    
    NSArray *paramPairs = [queryString componentsSeparatedByString:@"&"];
    if(paramPairs.count==0){
        return nil;
    }
    
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]initWithCapacity:paramPairs.count];
    for (NSString *paramPair in paramPairs) {
        NSArray *paramKeyValue = [paramPair componentsSeparatedByString:@"="];
        if(paramKeyValue.count==2){
            NSString *paramKey = paramKeyValue[0];
            NSString *paramValue = paramKeyValue[1];
            [paramDict setObject:paramValue forKey:paramKey];
        }
    }

    return paramDict.count==0 ? nil:paramDict;
}


@end
