//
//  DSHookPlugin.h
//  gongfudai
//
//  Created by EriceWang on 16/5/5.
//  Copyright © 2016年 dashu. All rights reserved.
//

#import "TBSPlugin.h"

@interface TBSHookPlugin : TBSPlugin
- (void)open:(NSDictionary*)command;
- (void)openHideView:(NSDictionary *)command;
@end
