//
//  CustomiseTool.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/1.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "CustomiseTool.h"
#import "DeviceConfig.h"

static NSString *KIsLoginCache = @"UserLoginCache";
static NSString *KLoginToken = @"UserLoginToken";

static NSString *KNightModel = @"NightModel";

static NSString *KCurrentVersion = @"CurrentVersion";
static NSString *KLanguageTypeCache = @"LanguageTypeCache";

static NSString *ZHLANGUAGE = @"zh-Hans";
static NSString *ENLANGUAGE = @"en";

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
    NSString *language = ZHLANGUAGE;
    if (type == LanguageTypeEn) {
        language = ENLANGUAGE;
    } else if (type == LanguageTypeZH) {
        language = ZHLANGUAGE;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj"];
    return [NSBundle bundleWithPath:path];
}

+ (LanguageType)languageType {
    return [[NSUserDefaults standardUserDefaults] integerForKey:KLanguageTypeCache];
}

+ (void)changeLanguage:(LanguageType)type oncompletion:(void(^)(void))comletion {
    if (type != [CustomiseTool languageType]) {
        [CustomiseTool setLanguage:type];
        comletion();
    }
}

+ (void)setLanguage:(LanguageType)type {
    
    [[NSUserDefaults standardUserDefaults] setInteger:type forKey:KLanguageTypeCache];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark
+ (long long)folderSizeAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    long long folderSize = 0;
    
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles = [fileManager subpathsAtPath:path];
        
        for (NSString *fileName in childerFiles) {
            NSString *fileAbsolutePath = [path stringByAppendingPathComponent:fileName];
            
            if ([fileManager fileExistsAtPath:fileAbsolutePath]) {
                long long size = [fileManager attributesOfItemAtPath:fileAbsolutePath error:nil].fileSize;
                folderSize += size;
            }
        }
    }
    
    return folderSize;
}

+ (long long)fileSizeAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {
        long long size = [fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return size;
    }
    
    return 0;
}

+ (void)clearCacheAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles = [fileManager subpathsAtPath:path];
        
        for (NSString *fileName in childerFiles) {
            NSString *fileAbsolutePath = [path stringByAppendingPathComponent:fileName];
            
            if ([fileManager fileExistsAtPath:fileAbsolutePath]) {
                [fileManager removeItemAtPath:fileAbsolutePath error:NULL];
            }
        }
    }
}

@end
