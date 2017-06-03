/********* progress.m Cordova Plugin Implementation *******/

#import "TBSProgressPlugin.h"
//#import <FontAwesomeKit.h>
#import "RKDropdownAlert.h"

@implementation TBSProgressPlugin

@synthesize hud = _hud;
@synthesize mode = _mode;

- (MBProgressHUD*)hud {
    if (!_hud) {
        if (_mode == DSCordovaProgressHUDModeOnTopWindow) {
            UIWindow* topWin = [self tbs_getWindow];
//            _hud = [[MBProgressHUD alloc] initWithWindow: topWin];
            _hud = [[MBProgressHUD alloc] initWithView:topWin];
            [topWin addSubview:_hud];
        } else {
            UIView* view  = self.webview;
            _hud = [[MBProgressHUD alloc] initWithView:view];
            [view addSubview:_hud];
            _mode = DSCordovaProgressHUDModeOnWebView;
        }
    }
    return _hud;
}

- (void)resetProgresHUD {
    [self.hud setMode:MBProgressHUDModeText];
//    [self.hud setLabelText:@""];
    self.hud.label.text = @"";
//    [self.hud setDetailsLabelText:@""];
    self.hud.detailsLabel.text = @"";
}

- (void)setMode:(DSCordovaProgressHUDMode)mode {
    if (mode != _mode) {
        _hud = nil;
    }
    _mode = mode;
}

- (UIWindow*)tbs_getWindow {
    NSEnumerator* frontToBackWindows = [[[UIApplication sharedApplication]windows]reverseObjectEnumerator];
    
    for (UIWindow* window in frontToBackWindows) {
        if (window.windowLevel == UIWindowLevelNormal && !window.hidden) {
            return window;
        }
    }
    return [UIApplication sharedApplication].keyWindow;
}

- (id) getParamFrom:(NSArray*)arguments atIndex:(NSInteger)index {
    id param = nil;
    if (index < [arguments count]) {
        param = [arguments objectAtIndex:index];
        if (param == [NSNull null]) {
            param = nil;
        }
    }
    return param;
}

- (void)showDropdown:(NSDictionary *)command {
    NSString* msg = [command objectForKey:@"msg"];
    NSString* title = [command objectForKey:@"title"];
    
    if (msg && msg.length) {
        [RKDropdownAlert title:title message:msg];
        [self sendResult:command code:DSOperationStateSuccess result:nil];
    } else {
        [self sendResult:command code:DSOperationStateParamsError result:nil];
    }
}

#pragma mark - 在当前View上显示MBProgressHUD

- (void)showLoading:(NSDictionary*)command {
    
    NSString *msg = [command objectForKey:@"msg"];
    if (!msg) {
        msg = [command objectForKey:@"key"];
    }
    if (msg && msg.length) {
        [self showLoading:msg mode:DSCordovaProgressHUDModeOnWebView];
        [self sendResult:command code:DSOperationStateSuccess result:nil];
    } else {
        [self sendResult:command code:DSOperationStateParamsError result:nil];
    }
}

- (void)showSuccess:(NSDictionary*)command {
    //    NSDictionary* pluginResult = nil;
    NSString *msg = [command objectForKey:@"msg"];
    if (!msg) {
        msg = [command objectForKey:@"key"];
    }
    
    if (msg && msg.length) {
        
        [self showSuccess:msg mode:DSCordovaProgressHUDModeOnWebView];
    } else {
        [self sendResult:command code:DSOperationStateParamsError result:nil];
    }
    
}
- (void)showFail:(NSDictionary*)command {
    NSString *msg = [command objectForKey:@"msg"];
    
    if (!msg) {
        msg = [command objectForKey:@"key"];
    }
    if (msg && msg.length) {
        [self showFail:msg mode:DSCordovaProgressHUDModeOnWebView];
        [self sendResult:command code:DSOperationStateSuccess result:nil];
    } else {
        [self sendResult:command code:DSOperationStateParamsError result:nil];
    }
    
    
    //    pluginResult = command.successResult;
    //    [command.delegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)showProgress:(NSDictionary *)command {
    
    float percentage = [[command objectForKey:@"percent"] floatValue];
    NSString *msg = [command objectForKey:@"msg"];
    NSString *detail = [command objectForKey:@"detail"];
    if (percentage > 0.000001) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showProgress:percentage andMessage:msg andDetail:detail mode:DSCordovaProgressHUDModeOnWebView];
        });
        [self sendResult:command code:DSOperationStateSuccess result:nil];
    } else {
        [self sendResult:command code:DSOperationStateParamsError result:nil];
    }
    
    
    
    
    
}

#pragma mark - 在当前Window上显示MBProgressHUD

- (void)showLoadingOnTopWindow:(NSDictionary*)command {
    
    
    NSString *msg = [command objectForKey:@"msg"];
    if (!msg) {
        msg = [command objectForKey:@"ky"];
    }
    if (msg && msg.length) {
        [self showLoading:msg mode:DSCordovaProgressHUDModeOnTopWindow];
        [self sendResult:command code:DSOperationStateSuccess result:nil];
    } else {
        [self sendResult:command code:DSOperationStateParamsError result:nil];
    }
    
}

- (void)showSuccessOnTopWindow:(NSDictionary*)command {
    NSString* msg = [command objectForKey:@"msg"];
    if (!msg) {
        msg = [command objectForKey:@"key"];
    }
    if (msg && msg.length) {
        [self showSuccess:msg mode:DSCordovaProgressHUDModeOnTopWindow];
        [self sendResult:command code:DSOperationStateSuccess result:nil];
    } else {
        [self sendResult:command code:DSOperationStateParamsError result:nil];
    }
}

- (void)showFailOnTopWindow:(NSDictionary*)command {
    
    NSString* msg = [command objectForKey:@"msg"];
    if (!msg) {
        msg = [command objectForKey:@"key"];
    }
    if (msg && msg.length) {
        [self showFail:msg mode:DSCordovaProgressHUDModeOnTopWindow];
        [self sendResult:command code:DSOperationStateSuccess result:nil];
    } else {
        [self sendResult:command code:DSOperationStateParamsError result:nil];
    }
}

- (void)showProgressOnTopWindow:(NSDictionary *)command {
    float percentage = [[command objectForKey:@"percent"]  floatValue];
    NSString* msg = [command objectForKey:@"msg"];
    NSString* detail = [command objectForKey:@"detail"];
    if (percentage > 0.000001) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self showProgress:percentage andMessage:msg andDetail:detail mode:DSCordovaProgressHUDModeOnTopWindow];
        });
        [self sendResult:command code:DSOperationStateSuccess result:nil ];
    } else {
        [self sendResult:command code:DSOperationStateParamsError result:nil];
    }
}

#pragma mark - 实际用于显示MBProgressHUD的函数
- (void)showLoading:(NSString*)msg mode:(DSCordovaProgressHUDMode)mode {
    [self setMode:mode];
    
    if (self.hud.mode != MBProgressHUDModeIndeterminate) {
        [self resetProgresHUD];
        [self.hud setMode:MBProgressHUDModeIndeterminate];
    }
    
//    [self.hud setLabelText:msg];
    self.hud.label.text = msg;
    [self.hud showAnimated:YES];
//    [self.hud show:YES];
}

- (void)showSuccess:(NSString*)msg mode:(DSCordovaProgressHUDMode)mode {
    [self setMode:mode];
    
    if (self.hud.mode != MBProgressHUDModeCustomView) {
        [self resetProgresHUD];
        [self.hud setMode:MBProgressHUDModeCustomView];
    }
    
//    [self.hud setLabelText:msg];
    self.hud.label.text = msg;
//    FAKIonIcons* icon = [FAKIonIcons iosCheckmarkOutlineIconWithSize:30];
//    [icon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
//    UIImage* image = [icon imageWithSize:CGSizeMake(30, 30)];
//    [self.hud setCustomView:[[UIImageView alloc] initWithImage:image]];
//    [self.hud show:YES];
    [self.hud showAnimated:YES];
}

- (void)showFail:(NSString*)msg mode:(DSCordovaProgressHUDMode)mode {
    [self setMode:mode];
    
    if (self.hud.mode != MBProgressHUDModeCustomView) {
        [self resetProgresHUD];
        [self.hud setMode:MBProgressHUDModeCustomView];
    }
    
//    [self.hud setLabelText:msg];
    self.hud.label.text = msg;
//    FAKIonIcons* icon = [FAKIonIcons iosCloseOutlineIconWithSize:30];
//    [icon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
//    UIImage* image = [icon imageWithSize:CGSizeMake(30, 30)];

//    [self.hud show:YES];
    [self.hud showAnimated:YES];
}

- (void)showProgress:(float)percentage andMessage:(NSString*)msg andDetail:(NSString*)detail mode:(DSCordovaProgressHUDMode)mode {
    [self setMode:mode];
    if (self.hud.mode != MBProgressHUDModeDeterminateHorizontalBar) {
        [self resetProgresHUD];
        [self.hud setMode:MBProgressHUDModeDeterminateHorizontalBar];
    }
    [self.hud setProgress:percentage];
    self.hud.label.text = msg;
    self.hud.detailsLabel.text = detail;
    [self.hud showAnimated:YES];
//    [self.hud setLabelText:msg];
//    [self.hud setDetailsLabelText:detail];
//    [self.hud show:YES];
}

- (void)hide:(NSDictionary *)command {
    
//    [self.hud hide:YES];
    [self.hud hideAnimated:YES];
    [self sendResult:command code:DSOperationStateSuccess result:nil];
}
- (void)showAlert:(NSDictionary *)command {
    NSString *title = [command objectForKey:@"title"];
    NSString *msg = [command objectForKey:@"msg"];
    NSArray *buttons = [command objectForKey:@"buttons"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    alertController.title = title?:@"提示";
    alertController.message = msg;
    UIAlertAction *action = nil;
    if (buttons) {
        for (NSString *message in buttons) {
            action = [UIAlertAction actionWithTitle:message style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self sendResult:command code:DSOperationStateSuccess result:message];
            }];
            [alertController addAction:action];
        }
    } else {
    NSString *message = @"我知道了";
        action = [UIAlertAction actionWithTitle:message style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self sendResult:command code:DSOperationStateSuccess result:message];
        }];
        [alertController addAction:action];
    }
    [self.viewController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - MBProgressHUDDelegate
-(void)hudWasHidden:(MBProgressHUD *)hud {
    self.hud = nil;
}

@end
