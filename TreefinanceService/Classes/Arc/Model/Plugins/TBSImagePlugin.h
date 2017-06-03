//
//  TBSImagePlugin.h
//  kaixindai
//
//  Created by EriceWang on 2017/2/23.
//  Copyright © 2017年 Ericdong. All rights reserved.
//

#import "TBSPlugin.h"

@interface TBSImagePlugin : TBSPlugin
//保存h5传回的base64图片
- (void)save:(NSDictionary *)command;
- (void)screen:(NSDictionary *)command;

@end
