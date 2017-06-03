//
//  TBSNavigationController.m
//  Pods
//
//  Created by EriceWang on 2017/5/27.
//
//

#import "TBSNavigationController.h"
#import "Header.h"

@interface TBSNavigationController ()

@end

@implementation TBSNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (UIViewController *)childViewControllerForStatusBarStyle
{
    NSString *className = NSStringFromClass(self.topViewController.class);
    DSLog(@"className = %@", className);
    if ([className hasPrefix:@"TBS"]) {
        return self.topViewController;
    }
    return nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
