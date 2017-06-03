//
//  NSObject+Swizzle.h
//  GFDSDK
//
//  Created by EriceWang on 16/5/18.
//  Copyright © 2016年 Hangzhou Tree Finance Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Swizzle)
+ (void)tbs_swizzingSel:(SEL)aSel withSel:(SEL)bSel;

+ (void)tbs_swizzingClassSel:(SEL)aSel withSel:(SEL)bSel;

@end
