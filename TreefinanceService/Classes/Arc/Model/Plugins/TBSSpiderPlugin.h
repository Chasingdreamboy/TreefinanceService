//
//  DSSpiderPlugin.h
//  ServicePlugin
//
//  Created by EriceWang on 2017/5/11.
//  Copyright © 2017年 Hangzhou Tree Finance Ltd. All rights reserved.
//

#import "TBSPlugin.h"

@interface TBSSpiderPlugin : TBSPlugin
- (void)resetTaskId:(NSDictionary *)command;
- (void)setJSParams:(NSDictionary *)command;
- (void)cancel:(NSDictionary *)command;
- (void)callback:(NSDictionary *)command;
- (void)recoverScenes:(NSDictionary *)command;//退出时恢复现场
@end
