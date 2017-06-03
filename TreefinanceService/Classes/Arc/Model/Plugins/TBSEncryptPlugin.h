//
//  DSEncryptPlugin.h
//  GFDSDK
//
//  Created by EriceWang on 16/6/1.
//  Copyright © 2016年 Hangzhou Tree Finance Ltd. All rights reserved.
//

#import "TBSPlugin.h"

@interface TBSEncryptPlugin : TBSPlugin
/**
 *  参数加密
 *
 *  @param command 获取需要加密的字典
 */
- (void)encrypt:(NSDictionary *)command;


@end
