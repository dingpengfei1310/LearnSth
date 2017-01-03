//
//  Utils.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/31.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserModel;

@interface Utils : NSObject

+ (void)remoAllObjects;

#pragma mark
+ (void)setIsLogin:(BOOL)login;
+ (BOOL)isLogin;

+ (void)setUserModel:(UserModel *)model;
+ (UserModel *)userModel;

+ (long long)folderSizeAtPath:(NSString *)path;
+ (long long)fileSizeAtPath:(NSString *)path;
+ (void)clearCacheAtPath:(NSString *)path;


@end
