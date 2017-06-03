//
//  DSWebViewController.m
//  kaixindai
//
//  Created by EriceWang on 2017/2/20.
//  Copyright © 2017年 Ericdong. All rights reserved.
//

#import "TBSWebViewController.h"
#import "TBSConfigParser.h"
#import <NJKWebViewProgress/NJKWebViewProgress.h>
#import <NJKWebViewProgress/NJKWebViewProgressView.h>
//#import "NJKWebViewProgress.h"
//#import "NJKWebViewProgressView.h"

#import <MJRefresh/MJRefreshGifHeader.h>
//#import "MJRefreshGifHeader.h"
#import "UIImage+DivedeGitToImages.h"
#import "UIImage+Resize.h"
#import <SDWebImage/UIImage+GIF.h>
#import "TBSBridge.h"
//#import "UIView+Screenshot.h"
#import <NYXImagesKit/UIView+Screenshot.h>
#import "RKDropdownAlert+Expand.h"
#import "UIViewController+Expand.h"
#define kHeight   80
#import <ImageIO/ImageIO.h>
#import <SDWebImage/UIImage+GIF.h>
#import <AFNetworking/AFNetworking.h>
#import <objc/message.h>
#import "Header.h"
@interface TBSWebViewController ()<NJKWebViewProgressDelegate, CAAnimationDelegate> {
    AFNetworkReachabilityManager *manager;
    BOOL isLoaded;
}
@property (strong, nonatomic) JSBridge *jsBridge;
//存储需要预先进行加载的plugin
@property (nonatomic, readwrite, strong) NSArray* startupPluginNames;
@property (strong,nonatomic,readwrite) NJKWebViewProgress* webViewProxy;
@property (strong,nonatomic,readwrite) NJKWebViewProgressView* progressView;
@property (strong, nonatomic) NSDictionary *pluginsMap;
@property (strong, nonatomic) UIView *con;
//@property (strong, nonatomic) UIImageView *loadingView;
@property (strong, nonatomic) UIActivityIndicatorView *loadingView;

@end

@implementation TBSWebViewController
float frameDurationAtIndex(NSUInteger index, CGImageSourceRef source) {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    }
    else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}
UIImage *animatedGIFWithData(NSData *data) {
    if (!data) {
        return nil;
    }
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    }
    else {
        NSMutableArray *images = [NSMutableArray array];
        
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            duration += frameDurationAtIndex(i, source);
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    
    return animatedImage;
}
UIImage *getGifFromImageName(NSString *name) {
    CGFloat scale = [UIScreen mainScreen].scale;
    if (scale > 1.0f) {
        NSString *retinaPath = [TBS_BUNDLE pathForResource:[name stringByAppendingString:@"@2x"] ofType:@"gif"];
        NSData *data = [NSData dataWithContentsOfFile:retinaPath];
        
        if (data) {
            return animatedGIFWithData(data);
        }
        NSString *path = [TBS_BUNDLE pathForResource:name ofType:@"gif"];
        data = [NSData dataWithContentsOfFile:path];
        if (data) {
            return animatedGIFWithData(data);
        }
        return [UIImage imageNamed:name];
    }
    else {
        NSString *path = [TBS_BUNDLE pathForResource:name ofType:@"gif"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        if (data) {
            return animatedGIFWithData(data);
        }
        
        return [UIImage imageNamed:name];
    }
}
#pragma initialize methods
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self loadSettings];
    }
    return self;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadSettings];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
}
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //获取静态配置
        [self loadSettings];
    }
    return self;
}
#pragma life cycle of the Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearLocalStorage) name:@"logout" object:nil];
    self.view.backgroundColor = [UIColor tbs_colorWithHexString:@"#f2f2f2" alpha:1.0];
    self.jsBridge = [[JSBridge alloc] initWithParentVC:self];
    _jsBridge.pluginsMap = self.pluginsMap;
//    self.allowRefresh = YES;
    //添加进度条
    [self registerWebviewProgress];
    if (self.usePCUA) {
        [self fakeUA];
    } else {
        [self applyCustomerUA];
    }
    self.previousTitle = self.title;
    //初始化时将_startPage赋值给previousUrl，防止加载失败
    if (!self.sendPost) {
        if ([_startPage hasPrefix:@"http"] || [_startPage hasPrefix:@"https://"]) {
            NSURL *url = nil;
            url = [NSURL URLWithString:_startPage];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            self.previousRequest = request;
            [self.webview loadRequest:request];
        } else {
            [self.webview loadHTMLString:_startPage baseURL:nil];
            self.previousRequest = self.webview.request;
        }
    } else {
        //发送Post
        if (self.postParams) {
            NSURL *url = [NSURL URLWithString:self.startPage];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            [request setHTTPMethod:@"POST"];
            NSString *body = self.postParams.tbs_queryStringValue;
            [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
            self.previousRequest = (NSURLRequest *)request;
            [self.webview loadRequest:request];
        }
    }

}
- (void)viewDidAppear:(BOOL)animated {
    [self.webview stringByEvaluatingJavaScriptFromString:@"window.JSBridge && JSBridge._handleMessageFromNative({eventName: 'viewappear',data:null})"];
    [super viewDidAppear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.webview stringByEvaluatingJavaScriptFromString:@"window.JSBridge && JSBridge._handleMessageFromNative({eventName: 'viewdisappear',data:null})"];
}
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
-(void)refreshWebview:(id)sender{
    //the last load hasnt finished
    if ([self.webview isLoading]) {
        [self.webview stopLoading];
    }
    if ([self.webview.scrollView.mj_header isRefreshing]) {
        [self.webview.scrollView.mj_header endRefreshing];
    }
    [self refreshAction];
}
- (void)refreshAction {
    NSURLRequest *request = self.webview.request;
    if (self.previousRequest) {
        [self.webview loadRequest:self.previousRequest];
    }  else {
        [self.webview loadRequest:request];
    }
}
-(void)registerWebviewProgress {
    _webViewProxy=[[NJKWebViewProgress alloc]init];
    [self.webview setDelegate: _webViewProxy];
    _webViewProxy.webViewProxyDelegate = self;
    _webViewProxy.progressDelegate = self;
    CGFloat progressBarHeight = 3.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    NSString *tintColorString = DS_GET(tintColorKey);
    UIColor *tintColor = [UIColor tbs_colorWithHexString:tintColorString alpha:1.0];
    _progressView.progressBarView.layer.backgroundColor=[tintColor CGColor];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.navigationController.navigationBar addSubview:_progressView];
}
- (void)loadSettings {
    TBSConfigParser *delegate = [[TBSConfigParser alloc] init];
    NSString *path = [TBS_BUNDLE pathForResource:@"config" ofType:@"xml"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSAssert(NO, @"ERROR: config.xml does not exist. Please run cordova-ios/bin/cordova_plist_to_config_xml path/to/project.");
        return;
    }
    NSURL *url = [NSURL fileURLWithPath:path];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    if (!parser) {
        NSLog(@"Failed to initialize XML parser!");
        return;
    }
    [parser setDelegate:delegate];
    if ([parser parse]) {
        self.pluginsMap = delegate.featureNames;
    } else {
        NSLog(@"config.xml parse fail!");
    }
}

-(void)useMobileViewPort{
    [_webview stringByEvaluatingJavaScriptFromString:@"var meta = document.createElement('meta');\
     meta.name = 'viewport';\
     meta.content = 'width=device-width,initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no';\
     document.getElementsByTagName('head').item(0).appendChild(meta);"];
}
//注入CSS
-(void) injectCss:(NSString*)css intoWebView:(UIWebView*)webView{
    [webView stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:@"if(document.all){\
      window.style='%@';\
      document.createStyleSheet('javascript:style');\
      }else{\
      var style = document.createElement('style');\
      style.type = 'text/css';\
      style.innerHTML='%@';\
      document.getElementsByTagName('head').item(0).appendChild(style);\
      }",css,css]
     ];
}

-(void) injectJs:(NSString *)js intoWebView:(UIWebView *)webView{
    [webView stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:@"var oHead = document.getElementsByTagName('HEAD').item(0);\
      var oScript = document.createElement('script');\
      oScript.language = 'javascript';\
      oScript.type = 'text/javascript';\
      oScript.text = %@;\
      oHead.appendChild(oScript);",js]
     ];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) {
        self.view = nil;
    }
    // Dispose of any resources that can be recreated.
}
#pragma UIWebviewDelegate method
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = request.URL;
    BOOL status = NO;
    SEL sel = @selector(webView:shouldStartLoadWithRequest:navigationType:);
    if ([self.jsBridge respondsToSelector:sel]) {
        status = ((BOOL(*)(id, SEL,id,id, NSInteger))objc_msgSend)(self.jsBridge , sel, webView,request, navigationType);
    }
    if (!status) {
        return NO;
    }
    if ([url.scheme isEqualToString:@"gap"]) {
        return NO;
    }
    if([url.scheme isEqualToString:@"gfdapp"]) {
        [self refreshWebview:nil];
        return NO;
    }
    if ([url.scheme isEqualToString:@"gfdbridge"]) {
        if ([url.host isEqualToString:@"saveimg"]) {
            //保存base64字符串二维码图片
            NSString *base64String = url.query;
            NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage *image = image = [UIImage imageWithData:data];
            if (image) {
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:error:contextInfo:), nil);
            }
            return NO;
        } else if ([url.host isEqualToString:@"screencap"]) {
            //保存屏幕截图（含二维码）
            UIImage *screenShot = [self.view imageByRenderingView];
            if (screenShot) {
                UIImageWriteToSavedPhotosAlbum(screenShot, self, @selector(image:error:contextInfo:), nil);
            }
            return  NO;
        } else if ([url.host isEqualToString:@"openurl"]) {
            NSString *queryString = url.query;
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:queryString]];
            return NO;
        }
    }
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (!_unneedResetItem) {
        [self tbs_addLeftBackBtn:^(UIButton *sender) {
            
        }];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_progressView setProgress:1.0];
    });
    if (!_con) {
        [self.view addSubview:self.con];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if ([self.jsBridge respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.jsBridge performSelector:@selector(webViewDidStartLoad:) withObject:webView];
    }}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    NSLog(@"error URl = %@", webView.request.URL);
    SEL sel = @selector(webView:didFailLoadWithError:);
    if ([self.jsBridge respondsToSelector:sel]) {
        ((void(*)(id, SEL,UIWebView*,NSError *))objc_msgSend)(self.jsBridge , sel, webView,error);
    }
    if (error.code == -999) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_progressView setProgress:0.0];
        if (_con) {
            [self removeLoadingViewWithAnimation:NO];
        }
    });
    if (error.code == -1009) {
        if (![webView.request.URL.absoluteString containsString:@"index.html"]) {
            NSString *url = webView.request.URL.absoluteString;
            BOOL invalidate = [url isEqual:[NSNull null]] || !url || !url.length;
            if (!invalidate) {
               self.previousRequest = webView.request;
                self.previousTitle = self.title;
            }
        }
        [self loadError];
    } else {
        NSString *url = webView.request.URL.absoluteString;
        BOOL invalidate = [url isEqual:[NSNull null]] || !url || !url.length;
        if (!invalidate) {
            self.previousRequest = webView.request;
            self.previousTitle = self.title;
        }
        //加载失败时取消去掉加载🐱
        if ([webView.scrollView.mj_header isRefreshing]) {
            [webView.scrollView.mj_header endRefreshing];
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView*)webView
{
    BOOL index = [webView.request.URL.absoluteString containsString:@"index.html"];
    if (index) {
        NSString *selString = [NSString stringWithFormat:@"changeStyle('%@')", DS_GET(btnColorKey)];
        if (selString) {
          [webView stringByEvaluatingJavaScriptFromString:selString];
        }
    }
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];//自己添加的，原文没有提到。
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_progressView setProgress:1.0 animated:YES];
        if (_con) {
            [self removeLoadingViewWithAnimation:NO];
        }
    });
    NSLog(@"finished url = %@", webView.request.URL);
    if ([self.jsBridge respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.jsBridge performSelector:@selector(webViewDidFinishLoad:) withObject:webView];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if ([_webview.scrollView.mj_header isRefreshing]) {
        [_webview.scrollView.mj_header endRefreshing];
    }
    NSString *url = webView.request.URL.absoluteString;
    if (![url containsString:@"index.html"]) {
        self.title = self.previousTitle;
        BOOL invalidate = [url isEqual:[NSNull null]] || !url || !url.length;
        if (!invalidate) {
            self.previousRequest = webView.request;
            self.previousTitle = self.title;
        }
    } else {
    }
}
- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    NSLog(@"progress = %@", @(progress));
    dispatch_async(dispatch_get_main_queue(), ^{
        [_progressView setProgress:progress animated:YES];
    });
}
- (void)loadError {
    NSString *path = [TBS_BUNDLE pathForResource:@"index" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    self.title = @"网络异常";
    [self.webview loadHTMLString:htmlString baseURL:[NSURL URLWithString:path]];

}
-(UIWebView *)webview{
    CGRect frame = CGRectZero;
    frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    if (!_webview) {
        _webview = [[UIWebView alloc] initWithFrame:frame];
        _webview.delegate = self;
        _webview.scrollView.backgroundColor = [UIColor clearColor];
        self.view.backgroundColor = [UIColor tbs_colorWithHexString:@"f2f2f2" alpha:1.0];
        _webview.backgroundColor = [UIColor clearColor];
        _webview.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [self useMobileViewPort];
        [self.view addSubview:self.webview];
    }
    return _webview;
}
#pragma for outside use
- (void)applyCustomerUA {
    [TBSUtil applyCustomerUA];
}
-(void)fakeUA{
    [TBSUtil fakeUA];
}
- (UIView *)con {
    //全遮罩覆盖
    if (!_con) {
        CGRect frame = self.view.bounds;
        CGPoint center = (CGPoint){self.view.tbs_width / 2.0 , self.view.tbs_height / 2.0};
        _con = [[UIView alloc] initWithFrame:frame];
        _con.backgroundColor = [UIColor tbs_colorWithHexString:@"#f2f2f2" alpha:1.0];
        _con.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _con.backgroundColor = [UIColor whiteColor];
        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _loadingView.center = center;
        _loadingView.color = [UIColor grayColor];
        [_con addSubview:_loadingView];
        [_loadingView startAnimating];
    }
    return _con;
}
- (void)removeLoadingViewWithAnimation:(BOOL)animated {
    if (animated) {
        CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"opacity"];
        ani.fromValue = @(1.0);
        ani.toValue = @(0.0);
        ani.duration = 0.3;
        ani.autoreverses = NO;
        ani.fillMode = kCAFillModeForwards;
        ani.removedOnCompletion = NO;
        ani.delegate = self;
        [_con.layer addAnimation:ani forKey:@"opacity"];
    } else {
        [_con removeFromSuperview];
        _con = nil;
    }
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        [_con.layer removeAnimationForKey:@"opacity"];
        [_con removeFromSuperview];
        self.con = nil;
    }
}
- (void)clearLocalStorage {
    
    //清除cookies,应用退出时清理功夫贷内存
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        if ([cookie.domain containsString:@"91gfd"]) {
            [storage deleteCookie:cookie];
        }
    }
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    
    
    
    [self.webview stringByEvaluatingJavaScriptFromString:@"localStorage.clear()"];
}
- (void)image:(UIImage *)image error:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [RKDropdownAlert title:@"保存提示" message:@"截图保存失败,请重新尝试"];
    } else {
        UIColor *bgColor = [UIColor tbs_colorWithHexString:@"5cb85c" alpha:1.0];
        UIColor *defaultColor = [UIColor tbs_colorWithHexString:@"EEEEEE" alpha:1.0];
        [RKDropdownAlert title:@"保存提示" message:@"截图保存成功" backgroundColor:bgColor textColor:defaultColor];
    }
}
- (void)dealloc {
    NSLog(@"控制器被释放了");
    _webview.delegate = nil;
    [_webview removeFromSuperview];
    _webview = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"logout" object:nil];

}
- (void)setCookies:(NSString *)cookies {
    NSArray *cookieArray = nil;
    if ([cookies isKindOfClass:[NSString class]]) {
        cookieArray = cookies.tbs_getSetFromJson;
        if (!cookieArray) {
            return;
        }
    } else if ([cookies isKindOfClass:[NSArray class]]) {
        cookieArray = (NSArray *)cookies;
    }
    
    if ([cookieArray isKindOfClass:[NSArray class]]) {
        NSHTTPCookie *cookie = nil;
        NSMutableDictionary *dic = nil;
        for (NSDictionary *element in cookieArray) {
            dic = [NSMutableDictionary dictionary];
            NSString *name = element[@"name"];
            if (name) {
             [dic setObject:name forKey:NSHTTPCookieName];
            }
            NSString *value = element[@"value"];
            if (value) {
                [dic setObject:value forKey:NSHTTPCookieValue];
            }
            NSString *domain = element[@"cookieDomain"];
            if (domain) {
                [dic setObject:domain forKey:NSHTTPCookieDomain];
            }
            NSString *cookiePath = element[@"cookiePath"];
            if (cookiePath) {
                [dic setObject:cookiePath forKey:NSHTTPCookiePath];
            }
            NSString *isSecure = element[@"isSecure"];
            if (isSecure) {
                [dic setObject:isSecure forKey:NSHTTPCookieSecure];
            }
            NSString *version = element[@"cookieVersion"];
            if (version) {
                [dic setObject:version forKey:NSHTTPCookieVersion];
            }
            NSString *cookieExpiryDate = element[@"cookieExpiryDate"];
            if (cookieExpiryDate) {
                [dic setObject:cookieExpiryDate forKey:NSHTTPCookieExpires];
            }
            NSString *hasDomainAttribute = element[@"hasDomainAttribute"];
            if (hasDomainAttribute) {
                [dic setObject:hasDomainAttribute forKey:@"hasDomainAttribute"];
            }
            NSString *hasPathAttribute = element[@"hasPathAttribute"];
            if (hasPathAttribute) {
                [dic setObject:hasPathAttribute forKey:@"hasPathAttribute"];
            }
            cookie = [[NSHTTPCookie alloc] initWithProperties:dic];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            NSLog(@"cookie = %@",cookie );
            dic = nil;
        }
    } else {
        NSLog(@"cookies参数异常!");
    }

}
- (void)setAllowRefresh:(BOOL)allowRefresh {
    if (_allowRefresh == allowRefresh) {
        return ;
    }
    _allowRefresh = allowRefresh;
    if (allowRefresh) {
        //添加刷新
        __weak typeof (self) weakSelf = self;
        self.webview.scrollView.mj_header
        = ({
            MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
                [weakSelf refreshWebview:nil];
            }];
            header.lastUpdatedTimeLabel.hidden = YES;
            header.stateLabel.hidden = YES;
            NSString *path = [TBS_BUNDLE pathForResource:@"refreshing@2x" ofType:@"gif"];
            NSData *data = [NSData dataWithContentsOfFile:path];
            NSArray *images = [UIImage tbs_praseGIFDataToImageArray:data];
            UIImage *temp = nil;
            CGSize size = CGSizeZero;
            NSMutableArray *newImages = [NSMutableArray array];
            for (UIImage *image in images) {
                size = CGSizeMake(image.size.width / 2.0, image.size.height / 2.0);
                temp = [image tbs_resizedImageToSize:size];
                [newImages addObject:temp];
            }
            [header setImages:newImages forState:MJRefreshStateIdle];
            [header setImages:newImages forState:MJRefreshStatePulling];
            [header setImages:newImages forState:MJRefreshStateRefreshing];
            header;
        });
        
    } else {
        self.webview.scrollView.mj_header = nil;
    }
}


@end
