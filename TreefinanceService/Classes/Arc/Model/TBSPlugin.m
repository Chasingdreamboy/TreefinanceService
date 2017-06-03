//
//  DSPlugin.m
//  kaixindai
//
//  Created by EriceWang on 2017/3/3.
//  Copyright © 2017年 Ericdong. All rights reserved.
//

#import "TBSPlugin.h"

@implementation TBSPlugin
//BOOL avaiableParameter(id original) {
//    if ([original isMemberOfClass:[NSNull class]]) {
//        return nil;
//    } else {
//        return original;
//    }
//}
- (TBSPlugin *)initWithController:(TBSWebViewController *)controller {
    self = [super init];
    if (self) {
        self.viewController = controller;
        self.webview = controller.webview;
    }
    return self;
}
- (void)sendResult:(NSDictionary *)params code:(DSOperationState)code result:(id)result {
    dispatch_async(dispatch_get_main_queue(), ^{
         [JSBridge callCallbackForWebView:self.webview params:params response:result code:code];
    });
   
}
@end
