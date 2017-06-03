//
//  DSJailPlugin.m
//  gongfudaiNew
//
//  Created by EriceWang on 16/8/1.
//  Copyright © 2016年 dashu. All rights reserved.
//

#import "TBSJailPlugin.h"
#import "TBSUtil.h"

@implementation TBSJailPlugin
- (void)check:(NSDictionary *)command {
    BOOL isJailBreak = [TBSUtil isj];
    [self sendResult:command code:DSOperationStateSuccess result:@(isJailBreak)];
    
}
- (void)params:(NSDictionary *)command {
    NSDictionary *params = [TBSUtil getAllParams];
    if (params) {
        [self sendResult:command code:DSOperationStateSuccess result:params];
    } else {
        [self sendResult:command code:DSOperationStateUnknownError result:@""];
    }
}

@end
