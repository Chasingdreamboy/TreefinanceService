//
//  NSDictionary+Expand.h
//  gongfudai
//
//  Created by EriceWang Lan on 15/8/14.
//  Copyright (c) 2017年 dashu. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary(Expand)
-(NSString*)tbs_json;
- (NSDictionary *)tbs_getParasWithEncrypt;
- (NSDictionary *)tbs_getParasWithoutEncript;
@end
