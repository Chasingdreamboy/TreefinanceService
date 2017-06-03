//
//  TBSHelper.m
//  Pods
//
//  Created by EriceWang on 2017/5/26.
//
//

#import "TBSHelper.h"
#import "macro.h"

@implementation TBSHelper
+ (NSBundle *)bundle {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [currentBundle URLForResource:@"TreefinanceService" withExtension:@"bundle"];
    
    NSBundle *resourceBundle = [NSBundle bundleWithURL:url];
    NSError *error = nil;
   BOOL load = [resourceBundle loadAndReturnError:&error];
    if (load) {
        NSLog(@"加载成功");
    } else {
        NSLog(@"加载失败, error = %@", error);
    }
    
    return resourceBundle;
}

@end
