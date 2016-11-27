//
//  Utils.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/31.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (void)remoAllObjects;

#pragma mark
+ (void)setIsLogin:(BOOL)login;
+ (BOOL)isLogin;

+ (void)setUserNickname:(NSString *)name;
+ (NSString *)userNickname;

+ (void)setChooseUserNotification;
+ (BOOL)haveChooseUserNotification;

@end
