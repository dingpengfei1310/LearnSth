//
//  CustomiseTool.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/1.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, LanguageType) {
    LanguageTypeAuto = 0,
    LanguageTypeZH,
    LanguageTypeEn
};

@interface CustomiseTool : NSObject

+ (void)remoAllCaches;

#pragma mark
+ (void)setIsLogin:(BOOL)login;
+ (BOOL)isLogin;

+ (void)setLoginToken:(NSString *)token;
+ (NSString *)loginToken;

+ (void)setNightModel:(BOOL)model;
+ (BOOL)isNightModel;//是否夜间模式

+ (void)setCurrentVersion;
+ (BOOL)isFirstLaunch;//是否（更新后）第一次启动

+ (NSBundle *)languageBundle;
+ (LanguageType)languageType;
+ (void)changeLanguage:(LanguageType)type;

@end
