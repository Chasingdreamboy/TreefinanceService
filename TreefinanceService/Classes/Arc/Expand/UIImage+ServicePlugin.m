//
//  UIImage+ServicePlugin.m
//  GFDSDK
//
//  Created by EriceWang on 2017/3/11.
//  Copyright © 2017年 Hangzhou Tree Finance Ltd. All rights reserved.
//

#import "UIImage+ServicePlugin.h"
#import"TBSHelper.h"

@implementation UIImage (ServicePlugin)
+ (UIImage *)tbs_getImageWithName:(NSString *)imageName {
    
    NSBundle *bundle = [TBSHelper bundle];
    UIImage *image = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
}
@end
