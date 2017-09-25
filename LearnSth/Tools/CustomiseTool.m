//
//  CustomiseTool.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/1.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "CustomiseTool.h"

static NSString *KIsLoginCache = @"UserLoginCache";
static NSString *KLoginToken = @"UserLoginToken";

static NSString *KCurrentVersion = @"CurrentVersion";
static NSString *KLanguageTypeCache = @"LanguageTypeCache";

static NSString *ZHLANGUAGE = @"zh-Hans";
static NSString *ENLANGUAGE = @"en";

@interface CustomiseTool ()
@end

@implementation CustomiseTool

+ (void)remoAllCaches {
    //    NSDictionary* dict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    //    for(NSString * key in [dict allKeys]) {
    //        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    //    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KIsLoginCache];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KLanguageTypeCache];
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

+ (void)setCurrentVersion {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [[NSUserDefaults standardUserDefaults] setFloat:version.floatValue forKey:KCurrentVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isFirstLaunch {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return [[NSUserDefaults standardUserDefaults] floatForKey:KCurrentVersion] < version.floatValue;
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

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1.0, 1.0);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    [color setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
