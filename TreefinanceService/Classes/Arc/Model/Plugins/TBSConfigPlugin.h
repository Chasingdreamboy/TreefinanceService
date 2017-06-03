//
//  GFDAppConfig.h
//  gongfudai
//
//  Created by EricyWang on 15/11/18.
//  Copyright © 2015年 dashu. All rights reserved.
//

#import "TBSPlugin.h"

@interface TBSConfigPlugin : TBSPlugin

- (void)load:(NSDictionary*)command;

- (void)get:(NSDictionary*)command;
//20160613  增加set方法byErice
-(void)set:(NSDictionary *)command;


@end
