//
//  CustomiseTool.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/1.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger){
    LanguageTypeZH = 1,
    LanguageTypeEn
} LanguageType;

@interface CustomiseTool : NSObject

+ (void)remoAllCaches;

#pragma mark
+ (void)setIsLogin:(BOOL)login;
+ (BOOL)isLogin;

+ (NSBundle *)languageBundle;
+ (void)changeLanguage:(LanguageType)type oncompletion:(void(^)())comletion;

+ (long long)folderSizeAtPath:(NSString *)path;
+ (long long)fileSizeAtPath:(NSString *)path;
+ (void)clearCacheAtPath:(NSString *)path;

+ (UIImage *)imageWithColor:(UIColor *)color;

@end
