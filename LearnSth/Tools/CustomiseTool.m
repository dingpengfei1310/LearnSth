//
//  CustomiseTool.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/1.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "CustomiseTool.h"
#import "DeviceConfig.h"
#import <sys/stat.h>

static NSString *const KIsLoginCache = @"UserLoginCache";
static NSString *const KLoginToken = @"UserLoginToken";

static NSString *const KNightModel = @"NightModel";

static NSString *const KCurrentVersion = @"CurrentVersion";
static NSString *const KLanguageTypeCache = @"LanguageTypeCache";

static NSString *const ZHLanguage = @"zh-Hans";
static NSString *const ENLanguage = @"en";

@interface CustomiseTool ()
@end

@implementation CustomiseTool

+ (void)remoAllCaches {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KIsLoginCache];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KLoginToken];
}

#pragma mark
+ (void)setIsLogin:(BOOL)login {
    [[NSUserDefaults standardUserDefaults] setBool:login forKey:KIsLoginCache];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isLogin {
    return [[NSUserDefaults standardUserDefaults] boolForKey:KIsLoginCache];
}

+ (void)setLoginToken:(NSString *)token {
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:KLoginToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)loginToken {
    return [[NSUserDefaults standardUserDefaults] stringForKey:KLoginToken];
}

+ (void)setNightModel:(BOOL)model {
    [[NSUserDefaults standardUserDefaults] setBool:model forKey:KNightModel];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isNightModel {
    return [[NSUserDefaults standardUserDefaults] boolForKey:KNightModel];
}

+ (void)setCurrentVersion {
    [[NSUserDefaults standardUserDefaults] setObject:[DeviceConfig getAppVersion] forKey:KCurrentVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isFirstLaunch {
    NSString *currentVersion = [DeviceConfig getAppVersion];
    NSString *cacheVersion = [[NSUserDefaults standardUserDefaults] stringForKey:KCurrentVersion];
    return ([cacheVersion compare:currentVersion] == NSOrderedAscending);
}

#pragma mark
+ (NSBundle *)languageBundle {
    LanguageType type = [CustomiseTool languageType];
    NSString *language = ZHLanguage;
    if (type == LanguageTypeAuto) {
        NSString *currentLanguage = [[NSBundle mainBundle] preferredLocalizations].firstObject;
        if ([currentLanguage containsString:ZHLanguage]) {
            language = ZHLanguage;
        } else {
            language = ENLanguage;
        }
    } else if (type == LanguageTypeEn) {
        language = ENLanguage;
    } else if (type == LanguageTypeZH) {
        language = ZHLanguage;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj"];
    return [NSBundle bundleWithPath:path];
}

+ (LanguageType)languageType {
    return [[NSUserDefaults standardUserDefaults] integerForKey:KLanguageTypeCache];
}

+ (void)changeLanguage:(LanguageType)type {
    if (type != [CustomiseTool languageType]) {
        [CustomiseTool setLanguage:type];
    }
}

+ (void)setLanguage:(LanguageType)type {
    [[NSUserDefaults standardUserDefaults] setInteger:type forKey:KLanguageTypeCache];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
