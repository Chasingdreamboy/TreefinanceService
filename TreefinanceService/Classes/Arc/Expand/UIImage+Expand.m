//
//  UIImage+Expand.m
//  gongfudai
//
//  Created by _tauCross on 14-6-9.
//  Copyright (c) 2014年 dashu. All rights reserved.
//

#import "UIImage+Expand.h"
#import <objc/runtime.h>
@implementation UIImage (Expand)

+ (UIImage *)tbs_imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)tbs_scaleToSize:(CGSize)size
{
    CGSize selfSize = self.size;
    CGSize reSize = size;
    CGFloat rw = reSize.width / selfSize.width;
    CGFloat rh = reSize.height / selfSize.height;
    CGFloat rate = MAX(rw, rh);
    UIGraphicsBeginImageContext(CGSizeMake(self.size.width * rate, self.size.height * rate));
    [self drawInRect:CGRectMake(0, 0, self.size.width * rate, self.size.height * rate)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGRect cutRect = CGRectMake((scaledImage.size.width - reSize.width) / 2, (scaledImage.size.height - reSize.height) / 2, reSize.width, reSize.height);
    CGImageRef imageRef = scaledImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, cutRect);
    
    UIGraphicsBeginImageContext(reSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, cutRect, subImageRef);
    UIImage *cutImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    
    return cutImage;
}



- (UIImage *) tbs_imageWithTintColor:(UIColor *)tintColor
{
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

-(UIImage*)tbs_getImageCornerRadius:(const CGFloat)radius {
    UIImage *image = self;
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    
    const CGRect RECT = CGRectMake(0, 0, image.size.width, image.size.height);
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:RECT cornerRadius:radius] addClip];
    // Draw your image
    [image drawInRect:RECT];
    
    // Get the image, here setting the UIImageView image
    //imageView.image
    UIImage* imageNew = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return imageNew;
}



@end
