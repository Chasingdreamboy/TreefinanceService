//
//  DSLoginHookViewController.m
//  gongfudai
//
//  Created by EriceWang Lan on 15/8/27.
//  Copyright (c) 2017年 dashu. All rights reserved.
//

#import "TBSLoginHookViewController.h"
#import "RegexKitLite.h"
#import "Header.h"
@interface TBSLoginHookViewController ()<NSURLConnectionDataDelegate>
{
    NSMutableArray* _headers;
    NSMutableDictionary* _cookieDict;
    NSMutableArray* _cookieArray;
    NSInteger _count;
    BOOL _done;
    NSInteger numbersRequest;
}
@end

@implementation TBSLoginHookViewController
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
    NSURLRequest *request = webView.request;
    NSArray* cookies=[[NSHTTPCookieStorage sharedHTTPCookieStorage]cookiesForURL:request.URL];
    [_cookieArray addObjectsFromArray:cookies];
    for (NSHTTPCookie* cookie in cookies) {
        [_cookieDict setObject:cookie.value forKey:cookie.name];
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
            
            if(reg!=nil&&js!=nil&&[url isMatchedByRegex:reg]){
                NSLog(@"key = %@",reg);
                NSLog(@"js = %@", js);
                
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
    BOOL matched=NO;
    NSString* _finishedUrl=[_endUrls objectAtIndex:_count];
    NSLog(@"%@",request.URL);
    if ([_finishedUrl isEqualToString:@""]||_finishedUrl==nil) {
        matched=NO;
    }
    else{
        matched=[DS_STR_FORMAT(@"%@", request.URL) isMatchedByRegex:_finishedUrl];

    }
    if (matched) {
        
        [[[NSURLConnection alloc]initWithRequest:request delegate:self]start];
        return NO;
    }
    return YES;
}
-(void)stopTracking:(NSURL*)url headers:(NSDictionary*)headers{
    NSMutableString * cookiesStr=[NSMutableString stringWithString:@""];
    for (NSString* key in [_cookieDict allKeys]) {
        NSString* cookieVal=[_cookieDict objectForKey:key];
        [cookiesStr appendFormat:@"%@=%@;",key,cookieVal];
    }
    if (!_done) {
        if (self.loginSucces) {
            self.loginSucces(self,@{@"website":_identifier,@"cookie":cookiesStr,@"url":DS_STR_FORMAT(@"%@", url),@"header":[headers tbs_json]});
        }
        _done=YES;
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSDictionary* headers=[(NSHTTPURLResponse*)response allHeaderFields];
    NSArray* cookies=[NSHTTPCookie cookiesWithResponseHeaderFields:headers forURL:response.URL];
    [_cookieArray addObjectsFromArray:cookies];
    for (NSHTTPCookie* cookie in cookies) {
        [_cookieDict setObject:cookie.value forKey:cookie.name];
    }
    ++_count;
    NSString* nextUrl=_count<_startUrls.count?[_startUrls objectAtIndex:_count]:nil;
    if (nextUrl!=nil&&![nextUrl isEqualToString:@""]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:nextUrl]];
        self.previousRequest = request;
        [self.webview loadRequest:request];
    }
    else{
        [self stopTracking:response.URL headers:headers];
    }
}



@end
