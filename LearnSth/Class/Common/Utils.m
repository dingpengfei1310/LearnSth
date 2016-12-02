//
//  Utils.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/31.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "Utils.h"

static NSString *IsLogin = @"UserLogin";
static NSString *UserAccount = @"UserAccount";

@implementation Utils

+ (void)remoAllObjects {
//    NSDictionary* dict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
//    for(NSString * key in [dict allKeys]) {
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
//    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:IsLogin];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserAccount];
    
}

#pragma mark
+ (void)setIsLogin:(BOOL)login {
    [[NSUserDefaults standardUserDefaults] setBool:login forKey:IsLogin];
}

+ (BOOL)isLogin {
    return [[NSUserDefaults standardUserDefaults] boolForKey:IsLogin];
}


#pragma mark
+ (void)setUserAccount:(NSString *)name {
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:UserAccount];
}

+ (NSString *)userAccount {
    return [[NSUserDefaults standardUserDefaults] stringForKey:UserAccount];
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


