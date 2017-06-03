//
//  UIImage+ServicePlugin.h
//  GFDSDK
//
//  Created by EriceWang on 2017/3/11.
//  Copyright © 2017年 Hangzhou Tree Finance Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ServicePlugin)
+ (UIImage *)tbs_getImageWithName:(NSString *)imageName;
@end
