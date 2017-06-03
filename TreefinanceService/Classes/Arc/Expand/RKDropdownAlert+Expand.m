//
//  RKDropdownAlert+Expand.m
//  gongfubao
//
//  Created by EriceWang on 15/12/10.
//  Copyright © 2015年 Hangzhou Tree Finance Ltd. All rights reserved.
//

#import "RKDropdownAlert+Expand.h"
#import "UIColor+Expand.h"


@interface PrivateDelegate : NSObject<RKDropdownAlertDelegate>
+ (instancetype)sharedInstance ;
@property (copy, nonatomic) TapClick callback;
@end
@implementation PrivateDelegate
+ (instancetype)sharedInstance {
    static PrivateDelegate *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance =  [[PrivateDelegate alloc] init];
    });
    return instance;
}

-(BOOL)dropdownAlertWasTapped:(RKDropdownAlert*)alert {
    if (self.callback) {
        self.callback(alert);
    }
    return YES;
}
-(BOOL)dropdownAlertWasDismissed {
    return YES;
}
@end

@implementation RKDropdownAlert (Expand)
+ (void)successWithTitle:(NSString *)title message:(NSString *)message withTapClick:(TapClick)callBack{
    if (callBack) {
        [PrivateDelegate sharedInstance].callback = callBack;
    }
    UIColor *bgColor = [UIColor tbs_colorWithHexString:@"6dae18" alpha:1.0];
    [self title:title message:message backgroundColor:bgColor textColor:nil delegate:[PrivateDelegate sharedInstance]];
    
}
+ (void)warningWithTitle:(NSString *)title message:(NSString *)message withTapClick:(TapClick)callBack{
    if (callBack) {
        [PrivateDelegate sharedInstance].callback = callBack;
    }
    UIColor *bgColor = [UIColor tbs_colorWithHexString:@"ffae00" alpha:1.0];
    [self title:title message:message backgroundColor:bgColor textColor:nil delegate:[PrivateDelegate sharedInstance]];
    
}
+ (void)errorWithTitle:(NSString *)title message:(NSString *)message withTapClick:(TapClick)callBack {
    if (callBack) {
        [PrivateDelegate sharedInstance].callback = callBack;
    }
    UIColor *bgColor = [UIColor tbs_colorWithHexString:@"e44142" alpha:1.0];
    [self title:title message:message backgroundColor:bgColor textColor:nil delegate:[PrivateDelegate sharedInstance]];
    
}
+ (void)notificationWithTitle:(NSString *)title message:(NSString *)message withTapClick:(TapClick)callBack{
    if (callBack) {
        [PrivateDelegate sharedInstance].callback = callBack;
    }
    [self title:title message:message backgroundColor:[UIColor redColor] textColor:[UIColor whiteColor] delegate:[PrivateDelegate sharedInstance]];
    
}

@end
