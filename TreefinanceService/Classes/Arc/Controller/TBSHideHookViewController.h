//
//  DSLoginHookViewController.h
//  gongfudai
//
//  Created by EriceWang Lan on 15/8/27.
//  Copyright (c) 2017年 dashu. All rights reserved.
//

#import "TBSWebViewController.h"

@interface TBSHideHookViewController : TBSWebViewController
@property(nonatomic,strong) NSArray* startUrls;
@property(nonatomic,strong) NSArray* endUrls;
@property(nonatomic,strong) NSString* identifier;
@property(nonatomic,strong) NSArray* css;
@property(nonatomic,strong) NSArray* js;
@property(nonatomic) BOOL saveCookie;


//for hideView
@property (assign, nonatomic) BOOL hiddeView;
@property (strong, nonatomic) NSArray *responseData;

@property(nonatomic,copy,readwrite) void (^(loginSucces))(TBSHideHookViewController *vc, id params);
@end
