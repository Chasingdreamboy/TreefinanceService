//
//  DSBusinessPlugin.h
//  gongfudai
//
//  Created by EricyWang on 15/11/18.
//  Copyright © 2015年 dashu. All rights reserved.
//

#import "TBSPlugin.h"

@interface TBSBusinessPlugin : TBSPlugin

//- (void)logWithStep:(NSDictionary*)command;
//- (void)logBlackBox:(NSDictionary*)command;
- (void)logAppInfo:(NSDictionary*)command;
@end
