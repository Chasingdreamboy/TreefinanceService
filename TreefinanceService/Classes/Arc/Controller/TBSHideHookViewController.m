//
//  DSLoginHookViewController.m
//  gongfudai
//
//  Created by EriceWang Lan on 15/8/27.
//  Copyright (c) 2017年 dashu. All rights reserved.
//

#import "TBSHideHookViewController.h"
#import "RegexKitLite.h"
#import "Header.h"
@interface TBSHideHookViewController ()<NSURLConnectionDataDelegate>
{
    NSMutableArray* _headers;
    NSMutableDictionary* _cookieDict;
    NSMutableArray* _cookieArray;
    NSInteger _count;
    BOOL _done;
    NSInteger numbersRequest;
}
@end

@implementation TBSHideHookViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    _headers=[NSMutableArray array];
    _cookieDict=[NSMutableDictionary dictionary];
    _cookieArray=[NSMutableArray array];
    _count=0;
    _done=NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)webViewDidStartLoad:(UIWebView *)webView {
    numbersRequest++;
    [super webViewDidStartLoad:webView];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    numbersRequest--;
    [super webView:webView didFailLoadWithError:error];
    if (!numbersRequest) {
        NSString *url = [NSString stringWithFormat:@"%@", webView.request.URL];
        [self injectJS:webView url:url];
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    numbersRequest--;
    [super webViewDidFinishLoad:webView];
    NSString* url=DS_STR_FORMAT(@"%@", webView.request.URL);
    NSURLRequest *request = webView.request;
    
    

    BOOL matched=NO;
    NSString* _finishedUrl=[_endUrls objectAtIndex:_count];
    if ([_finishedUrl isEqualToString:@""]||_finishedUrl==nil) {
        matched=NO;
    } else {
        matched=[DS_STR_FORMAT(@"%@", request.URL) isMatchedByRegex:_finishedUrl];
        if (self.hiddeView) {
            NSString *current = DS_STR_FORMAT(@"%@", request.URL);
            NSLog(@"match = %d, current = %@, finishUrl = %@",matched, current, _finishedUrl);
        }
    }
    if (matched) {
        if (self.hiddeView) {
            _count++;
        }
        NSString* nextUrl=_count<_startUrls.count?[_startUrls objectAtIndex:_count]:nil;
        if (nextUrl!=nil&&![nextUrl isEqualToString:@""]) {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:nextUrl]];
            self.previousRequest = request;
            [self.webview loadRequest:request];
        }
    }
    //js 注入
    if (!numbersRequest) {
        NSString *url = [NSString stringWithFormat:@"%@", webView.request.URL];
        [self injectJS:webView url:url];
    }
    //css 注入
    if (_css!=nil) {
        [_css enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop) {
            NSString* reg=[item objectForKey:@"key"];
            NSString* css=[item objectForKey:@"value"];
            if(reg!=nil&&css!=nil&&[url isMatchedByRegex:reg]){
                [self injectCss:css intoWebView:webView];
            }
        }];
    }
    NSArray* cookies=[[NSHTTPCookieStorage sharedHTTPCookieStorage]cookiesForURL:request.URL];
    [_cookieArray addObjectsFromArray:cookies];
    for (NSHTTPCookie* cookie in cookies) {
        [_cookieDict setObject:cookie.value forKey:cookie.name];
    }
    if (_count == _startUrls.count && self.hiddeView) {
        NSMutableString * cookiesStr=[NSMutableString stringWithString:@""];
        for (NSString* key in [_cookieDict allKeys]) {
            NSString* cookieVal=[_cookieDict objectForKey:key];
            [cookiesStr appendFormat:@"%@=%@;",key,cookieVal];
        }
        NSString
        *jsToGetHTMLSource =
        @"document.getElementsByTagName('html')[0].innerHTML";
        NSString *HTMLSource = [self.webview
                                stringByEvaluatingJavaScriptFromString:jsToGetHTMLSource];
        NSMutableDictionary *content = [NSMutableDictionary dictionary];
        if ([self.responseData containsObject:@"cookie"]) {
            [content setObject:cookiesStr forKey:@"cookie"];
        }
        if ([self.responseData containsObject:@"html"]) {
            [content setObject:HTMLSource forKey:@"html"];
        }
        if (_loginSucces) {
            _loginSucces(self,content);
        }
    } else {
        DSLog(@"CCCC, count = %@, co = %@, hide = %@", @(_count),@(_startUrls.count), @(self.hiddeView));
    }
}
- (void)injectJS:(UIWebView *)webView  url:(NSString *)url {
    //js 注入
    if (_js==nil) {
        [webView stringByEvaluatingJavaScriptFromString :@"document.querySelector('input[type=text]').focus()"];
    }
    else{
        [_js enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop) {
            NSString* reg=[item objectForKey:@"key"];
            NSString* js=[item objectForKey:@"value"];
//            DSLog(@"js = %@", js);
            if(reg!=nil&&js!=nil&&[url isMatchedByRegex:reg]){
                NSLog(@"key = %@",reg);
                [webView stringByEvaluatingJavaScriptFromString:js];
            }
        }];
    }
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    BOOL result=[super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    if(!result){
        return NO;
    }
    if (request.URL==nil) {
        return NO;
    }
    
    if (self.hiddeView) {
        NSString* str =  DS_STR_FORMAT(@"%@", request.URL);
        DSLog(@"str = %@, url = %@", str, self.startPage);
    }
    NSLog(@"\n\n正在请求>>>>>>>>>>>%@",request.URL);
    NSArray* cookies=[[NSHTTPCookieStorage sharedHTTPCookieStorage]cookiesForURL:request.URL];
    [_cookieArray addObjectsFromArray:cookies];
    for (NSHTTPCookie* cookie in cookies) {
        [_cookieDict setObject:cookie.value forKey:cookie.name];
    }

    return YES;
}

@end
