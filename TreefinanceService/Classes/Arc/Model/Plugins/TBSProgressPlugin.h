//
//  GFDProgress.h
//  CordovaTester
//
//  Created by EricyWang on 15/11/5.
//
//

#import "TBSPlugin.h"

#import <MBProgressHUD/MBProgressHUD.h>
//#import "MBProgressHUD.h"






typedef NS_ENUM(NSInteger, DSCordovaProgressHUDMode) {
    DSCordovaProgressHUDModeOnWebView,
    DSCordovaProgressHUDModeOnTopWindow
};

@interface TBSProgressPlugin : TBSPlugin<MBProgressHUDDelegate> {}

@property(nonatomic, strong) MBProgressHUD* hud;
@property(nonatomic, assign) DSCordovaProgressHUDMode mode;
@property(nonatomic, copy) NSString* callbackId;

- (void)showLoading:(NSDictionary*)command;
- (void)showSuccess:(NSDictionary*)command;
- (void)showFail:(NSDictionary*)command;
- (void)showProgress:(NSDictionary*)command;
- (void)showDropdown:(NSDictionary*)command;
- (void)hide:(NSDictionary*)command;
- (void)showAlert:(NSDictionary *)command;

@end
