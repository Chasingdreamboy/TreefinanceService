/********* controller.m Cordova Plugin Implementation *******/

#import "TBSControllerPlugin.h"
#import "TBSJSONUtil.h"
//#import <Cordova/CDVViewController.h>
#import "TBSWebViewController.h"
#import "TBSEnteranceController.h"
#import <objc/message.h>
//#import "DSBaseCDVBridgeViewController.h"
#import "Header.h"

@implementation TBSControllerPlugin
- (void)push:(NSDictionary *)command {
    
    NSString* type = [command objectForKey:@"type"];
    if ([@"class" isEqualToString:type]) {
        NSString* classStr = [command objectForKey:@"className"];
        NSString* title = [command objectForKey:@"title"];
        UIViewController* vc = [[NSClassFromString(classStr) alloc] init];
        vc.title = title;
        vc.hidesBottomBarWhenPushed = YES;
        [self.viewController.navigationController pushViewController:vc animated:YES];
        [self sendResult:command code:DSOperationStateSuccess result:nil];
        
    } else if ([@"url" isEqualToString:type]) {
        
        NSString* url = [command objectForKey:@"url"];
        NSString* title = [command objectForKey:@"title"];
        NSString* classStr = [command objectForKey:@"className"];
        if (!classStr) {
            classStr = NSStringFromClass([TBSWebViewController class]);
        } /*else {
            [self sendResult:command code:DSOperationStateParamsError result:nil];
        }*/
        TBSWebViewController* vc = [[NSClassFromString(classStr) alloc] init];
        vc.sendPost = [[command objectForKey:@"post"] boolValue];
        vc.postParams = [command objectForKey:@"postParams"];
        vc.title = title ? : @"";
        vc.hidesBottomBarWhenPushed = YES;
        vc.startPage = [TBSUtil getUrlWithParams:url];
        [self.viewController.navigationController pushViewController:vc animated:YES];
        [self sendResult:command code:DSOperationStateSuccess result:nil];
    }
    
}

- (void)pop:(NSDictionary *)command {
    
    if ([self.webview isLoading]) {
        [self.webview stopLoading];
    }
    if (!(self.viewController.navigationController.viewControllers.count<1)) {
        
        if ([self.viewController isKindOfClass:[TBSEnteranceController class]]) {
            TreefinanceService *service = [TreefinanceService sharedInstance];
            SEL sel = NSSelectorFromString(@"backToApp");
            NSMethodSignature *sig = [service methodSignatureForSelector:sel];
            if (sig) {
                ((void(*)(id, SEL))objc_msgSend)(service, sel);
                NSLog(@"backToApp");
            } else {
                NSLog(@"backToApp not found!");
            }
        } else {
            
            [self.viewController.navigationController popViewControllerAnimated:NO];
        }
        
        [self sendResult:command code:DSOperationStateSuccess result:nil];
    } else {
        [self sendResult:command code:DSOperationStateParamsError result:nil];
    }
}

-(void)popTo:(NSDictionary *)command {
    NSString *popToNumber = [NSString stringWithFormat:@"%@", [command objectForKey:@"popToNumber"]];
    if (!popToNumber || !popToNumber.length) {
        [self sendResult:command code:DSOperationStateParamsError result:nil];
        return;
    }
    NSInteger popNum = [popToNumber integerValue];
    NSArray* vcStack = self.viewController.navigationController.viewControllers;
    if (vcStack.count < popNum) {
        [self.viewController.navigationController popToRootViewControllerAnimated:YES];
    } else {
        UIViewController* vc = [vcStack objectAtIndex:([vcStack count] - popNum)];
        [self.viewController.navigationController popToViewController:vc animated:YES];
    }
    [self sendResult:command code:DSOperationStateSuccess result:nil];
}

- (void)exit:(NSDictionary *)command {
    [self pop:command];
}
- (void)logout:(NSDictionary *)command {
    [[TBSJSONUtil sharedInstance] logout];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:nil];
    [self sendResult:command code:DSOperationStateSuccess result:nil];
    
}
- (void)refresh:(NSDictionary *)command {
    BOOL allowRefresh  = [[command objectForKey:@"allowRefresh"] boolValue];
    TBSWebViewController *web = (TBSWebViewController *)self.viewController;
    web.allowRefresh = allowRefresh;
}
@end
