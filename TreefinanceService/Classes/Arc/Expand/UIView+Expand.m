//
//  UIView+Expand.m
//  gongfudai
//
//  Created by _tauCross on 14-7-16.
//  Copyright (c) 2014年 dashu. All rights reserved.
//

#import "UIView+Expand.h"

@implementation UIView (Expand)

- (void)setTbs_x:(CGFloat)x
{
    self.frame = CGRectMake(x, self.tbs_y, self.tbs_width, self.tbs_height);
}

- (CGFloat)tbs_x
{
    return self.frame.origin.x;
}

- (void)setTbs_y:(CGFloat)y
{
    self.frame = CGRectMake(self.tbs_x, y, self.tbs_width, self.tbs_height);
}

- (CGFloat)tbs_y
{
    return self.frame.origin.y;
}

- (void)setTbs_width:(CGFloat)width
{
    self.frame = CGRectMake(self.tbs_x, self.tbs_y, width, self.tbs_height);
}

- (CGFloat)tbs_width
{
    return self.frame.size.width;
}

- (void)setTbs_height:(CGFloat)height
{
    self.frame = CGRectMake(self.tbs_x, self.tbs_y, self.tbs_width, height);
}

- (CGFloat)tbs_height
{
    return self.frame.size.height;
}

- (void)setTbs_top:(CGFloat)top
{
    self.tbs_y = top;
}

- (CGFloat)tbs_top
{
    return self.tbs_y;
}

- (void)setTbs_bottom:(CGFloat)bottom
{
    self.frame = CGRectMake(self.tbs_x, bottom - self.tbs_height, self.tbs_width, self.tbs_height);
}

- (CGFloat)tbs_bottom
{
    return self.tbs_y + self.tbs_height;
}

- (void)setTbs_left:(CGFloat)left
{
    self.tbs_x = left;
}

- (CGFloat)tbs_left
{
    return self.tbs_x;
}

- (void)setTbs_right:(CGFloat)right
{
    self.frame = CGRectMake(right - self.tbs_width, self.tbs_y, self.tbs_width, self.tbs_height);
}

- (CGFloat)tbs_right
{
    return self.tbs_x + self.tbs_width;
}

- (void)setTbs_centerX:(CGFloat)centerX
{
    self.center = CGPointMake(centerX, self.tbs_centerY);
}

- (CGFloat)tbs_centerX
{
    return self.center.x;
}

- (void)setTbs_centerY:(CGFloat)centerY
{
    self.center = CGPointMake(self.tbs_centerX, centerY);
}

- (CGFloat)tbs_centerY
{
    return self.center.y;
}

- (CGSize)tbs_size {
    return self.frame.size;
}

- (void)setTbs_size:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGPoint)tbs_origin
{
    return self.frame.origin;
}

- (void)setTbs_origin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

//视图相对于自身视图的中心点
- (CGPoint)tbs_centerToSuper {
    return CGPointMake(self.tbs_centerX - self.tbs_x, self.tbs_centerY - self.tbs_y);
}
- (void)setTbs_centerToSuper:(CGPoint)centerToSuper {
    self.center = CGPointMake(self.tbs_x + centerToSuper.x, self.tbs_y + centerToSuper.y);
}

@end
