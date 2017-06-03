//
//  TBSEnteranceController.m
//  ServicePlugin
//
//  Created by EriceWang on 2017/5/9.
//  Copyright © 2017年 Hangzhou Tree Finance Ltd. All rights reserved.
//

#import "TBSEnteranceController.h"
#import "UIViewController+Expand.h"
#import <objc/message.h>
#import "Header.h"

@interface TBSEnteranceController ()

@end

@implementation TBSEnteranceController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.unneedResetItem = YES;
    [self tbs_addLeftBackBtn:^(UIButton *sender) {
        TreefinanceService *plugin = [TreefinanceService sharedInstance] ;
        SEL sel = NSSelectorFromString(@"backToApp");
        if ([plugin respondsToSelector:sel]) {
            ((void(*)(id,SEL))objc_msgSend)(plugin, sel);
        } else {
            
        }
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"控制器被释放了");
    [self.webview setDelegate:nil];
    [self.webview removeFromSuperview];
    self.webview = nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
