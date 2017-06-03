//
//  DSPlugin.h
//  kaixindai
//
//  Created by EriceWang on 2017/3/3.
//  Copyright © 2017年 Ericdong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBSBridge.h"
#import "TBSWebViewController.h"
#import "Authorization.h"
BOOL avaiableParameter(id original);
@interface TBSPlugin : NSObject

@property (strong, nonatomic) UIWebView *webview;
@property (assign, nonatomic) TBSWebViewController *viewController;
- (TBSPlugin *)initWithController:(TBSWebViewController *)controller;
//调用callback
- (void)sendResult:(NSDictionary *)params code:(DSOperationState)code result:(id)result;
@end
