//
//  DSWebViewController.h
//  kaixindai
//
//  Created by EriceWang on 2017/2/20.
//  Copyright © 2017年 Ericdong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface TBSWebViewController : UIViewController<UIWebViewDelegate>
@property(nonatomic) BOOL usePCUA;
@property (assign, nonatomic) BOOL unneedResetItem;//是否需要在加载时重置左右按钮
@property (copy, nonatomic) NSString *startPage;
@property (strong, nonatomic) UIWebView *webview;
@property (strong, nonatomic) NSURLRequest *previousRequest;
@property (copy, nonatomic) NSString *previousTitle;
@property (assign, nonatomic) BOOL sendPost;
@property (strong, nonatomic) NSDictionary *postParams;
@property (strong, nonatomic) NSString *headers;
@property (assign, nonatomic) BOOL allowRefresh;
- (void)setCookies:(NSString *)cookies;
//注入css
-(void) injectCss:(NSString*)css intoWebView:(UIWebView*)webView;
//注入JS
-(void) injectJs:(NSString *)js intoWebView:(UIWebView *)webView;


-(void)refreshWebview:(id)sender;
- (void)refreshAction;
-(void) fakeUA;
//- (void)applyCustomerUA;
@end
