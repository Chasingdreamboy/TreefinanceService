//
//  TBViewController.m
//  TreefinanceService
//
//  Created by acct<blob>=<NULL> on 05/26/2017.
//  Copyright (c) 2017 acct<blob>=<NULL>. All rights reserved.
//

#import "TBViewController.h"
#import <TreefinanceService/TreefinanceService-umbrella.h>

@interface TBViewController () {
    DSWebLoginType type;
}
@property (strong, nonatomic) UIAlertController *controller;

@end

@implementation TBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    type = -2;
	// Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)selectEnviroment:(UIButton *)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"环境选择" message:@"请选择环境" preferredStyle:UIAlertControllerStyleActionSheet] ;
    [alert addAction:({
        UIAlertAction *test = [UIAlertAction actionWithTitle:@"预发布环境" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
             [userDefault setObject:@"0" forKey:@"enviroment"];
            [sender setTitle:@"预发布环境" forState:UIControlStateNormal];
            [userDefault synchronize];
        }];
        test;
    })];
    [alert addAction:({
        UIAlertAction *prepare = [UIAlertAction actionWithTitle:@"测试环境" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [userDefault setObject:@"1" forKey:@"enviroment"];
            [sender setTitle:@"测试环境" forState:UIControlStateNormal];
        }];
        prepare;
    })];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)selectType:(UIButton *)sender {
    NSString *message = nil;
    if (sender.tag == 7001) {
        message = @"您选择了  邮箱";
        type = DSWebLoginTypeEmail;
    } else if(sender.tag == 7002) {
        message = @"您选择了  电商";
        type = DSWebLoginTypeEcommerce;
    } else if (sender.tag == 7003){
        message = @"您选择了  运营商";
        type = DSWebLoginTypeOperater;
    }
    self.controller.title = @"类型选择";
    self.controller.message = message;
    [self.controller addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.controller = nil;
        }];
        action;
    })];
    [self.controller addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            type = -2;
            self.controller = nil;
        }];
        action;
    })];
    [self presentViewController:self.controller animated:YES completion:nil];
    
}
- (IBAction)clickAction:(UIButton *)sender {
    BOOL validate = (type == DSWebLoginTypeEmail) || (type == DSWebLoginTypeEcommerce) || (type == DSWebLoginTypeOperater);
    if (!validate) {
        self.controller.title = @"错误提示";
        self.controller.message = @"请先选择测试类型：邮箱，电商，运营商";
        [self.controller addAction:({
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.controller = nil;
            }];
            action;
        })];
        [self presentViewController:self.controller animated:YES completion:^{
            
        }];
        return;
    }
    TreefinanceService *plugin = [TreefinanceService sharedInstance];
    [plugin start:@"5432345" latitude:@"30" longtitude:@"120" coorType:@"wgs84ll" appendParameters:@{} type:type extra:nil callback:^(NSInteger resultStatus, NSString * _Nullable taskId, NSString * _Nullable uniqueId, NSString * _Nullable params) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            NSString *status = [NSString stringWithFormat:@"status : %@\ntaskId : %@, params = %@", @(resultStatus), taskId, params];
//            self.controller.title = @"回调成功";
//            self.controller.message = status;
//            [self.controller addAction:({
//                UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                    self.controller = nil;
//                }];
//                action;
//            })];
//            [self presentViewController:self.controller animated:YES completion:^{
//                type = -1;
//            }];
//        });
    }];
    
}
- (UIAlertController *)controller {
    if (!_controller) {
        _controller = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    }
    return _controller;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
