//
//  UIImage+Expand.h
//  gongfudai
//
//  Created by _tauCross on 14-6-9.
//  Copyright (c) 2014年 dashu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  {
    tbs_topToBottom = 0,//从上到下
    tbs_leftToRight = 1,//从左到右
    tbs_upleftTolowRight = 2,//左上到右下
    tbs_uprightTolowLeft = 3,//右上到左下
}TBSGradientType;

@interface UIImage (Expand)

+ (UIImage *)tbs_imageWithColor:(UIColor *)color size:(CGSize)size;
- (UIImage *)tbs_scaleToSize:(CGSize)size;
- (UIImage *) tbs_imageWithTintColor:(UIColor *)tintColor;
-(UIImage*)tbs_getImageCornerRadius:(const CGFloat)radius;

@end
