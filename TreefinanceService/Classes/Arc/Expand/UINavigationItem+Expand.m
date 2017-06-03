//
//  UINavigationItem+Expand.m
//  gongfudai
//
//  Created by _tauCross on 14-7-23.
//  Copyright (c) 2014年 dashu. All rights reserved.
//

#import "UINavigationItem+Expand.h"
#import "Header.h"

@implementation UINavigationItem (Expand)

- (void)tbs_setLeftBarButtonItem:(UIBarButtonItem *)_leftBarButtonItem
{
    if (!_leftBarButtonItem) {
        self.leftBarButtonItems = @[];
        return;
    }
    if (IOS_OR_LATER(7.0))
    {
        UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSeperator.width = -10;
        
        if (_leftBarButtonItem)
        {
            [self setLeftBarButtonItems:@[negativeSeperator, _leftBarButtonItem]];
        }
        else
        {
            [self setLeftBarButtonItems:@[negativeSeperator]];
        }
    }
    else
    {
        [self setLeftBarButtonItem:_leftBarButtonItem animated:NO];
    }
}

- (void)tbs_setRightBarButtonItem:(UIBarButtonItem *)_rightBarButtonItem
{
    
    if (IOS_OR_LATER(7.0))
    {
        UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSeperator.width = -12;
        
        if (_rightBarButtonItem)
        {
            [self setRightBarButtonItems:@[negativeSeperator,_rightBarButtonItem]];
        }
        else
        {
            [self setRightBarButtonItems:@[negativeSeperator]];
        }
    }
    else
    {
        [self setRightBarButtonItem:_rightBarButtonItem animated:NO];
    }
}

@end
