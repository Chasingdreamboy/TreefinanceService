//
//  NSUserDefaults+Decrypt.h
//  kaixindai
//
//  Created by EriceWang on 2017/3/4.
//  Copyright © 2017年 Ericdong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Decrypt)
- (id)tbs_objectForKey:(NSString *)defaultName;
- (void)tbs_setObject:(id)value forKey:(NSString *)defaultName;
@end
