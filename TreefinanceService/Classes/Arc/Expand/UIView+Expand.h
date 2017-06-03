//
//  UIView+Expand.h
//  gongfudai
//
//  Created by _tauCross on 14-7-16.
//  Copyright (c) 2014年 dashu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Expand)

@property(nonatomic, assign)CGFloat tbs_x;
@property(nonatomic, assign)CGFloat tbs_y;
@property(nonatomic, assign)CGFloat tbs_width;
@property(nonatomic, assign)CGFloat tbs_height;
@property(nonatomic, assign)CGFloat tbs_top;
@property(nonatomic, assign)CGFloat tbs_bottom;
@property(nonatomic, assign)CGFloat tbs_left;
@property(nonatomic, assign)CGFloat tbs_right;
@property(nonatomic, assign)CGFloat tbs_centerX;
@property(nonatomic, assign)CGFloat tbs_centerY;
@property(nonatomic, assign)CGPoint tbs_origin;

@property (assign, nonatomic) CGPoint tbs_centerToSuper;

@property (nonatomic) CGSize tbs_size;


@end
