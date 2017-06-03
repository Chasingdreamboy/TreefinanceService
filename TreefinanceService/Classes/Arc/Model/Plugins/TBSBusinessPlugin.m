//
//  DSBusinessPlugin.m
//  gongfudai
//
//  Created by EricyWang on 15/11/18.
//  Copyright © 2015年 dashu. All rights reserved.
//

#import "TBSBusinessPlugin.h"
#import "TBSUtil.h"

@implementation TBSBusinessPlugin

//-(void)logWithStep:(NSDictionary *)command {
//    NSString* step = [command objectForKey:@"step"];
//    if (step && step.length) {
//        [DSUtil getLocationWithGPS:^(BOOL success) {
//            [DSUtil logWithStep:step];
//            [self sendResult:command code:DSOperationStateSuccess result:nil];
//        }];
//    } else {
//        [self sendResult:command code:DSOperationStateParamsError result:nil];
//    }
//}

//- (void)logBlackBox:(NSDictionary *)command {
//    NSString* blackbox = [command objectForKey:@"step"];
//    if (blackbox && blackbox.length) {
//        [DSUtil blackboxWithStep:blackbox];
//        [self sendResult:command code:DSOperationStateSuccess result:nil];
//    } else {
//        [self sendResult:command code:DSOperationStateParamsError result:nil];
//    }
//}

- (void)logAppInfo:(NSDictionary*)command{
    NSString* step= [command objectForKey:@"step"];
    if (step && step.length) {
        [TBSUtil uploadAppInfoWithStep:step];
        [self sendResult:command code:DSOperationStateSuccess result:nil];
    } else {
        [self sendResult:command code:DSOperationStateParamsError result:nil];
    }
}


@end
