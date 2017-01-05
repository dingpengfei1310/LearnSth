//
//  Utils.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/31.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "Utils.h"

#import "UserModel.h"

static NSString *KIsLoginCache = @"UserLoginCache";
static NSString *KUserModelCache = @"UserModelCache";

@implementation Utils

+ (void)remoAllObjects {
//    NSDictionary* dict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
//    for(NSString * key in [dict allKeys]) {
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
//    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KIsLoginCache];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KUserModelCache];
}

#pragma mark
+ (void)setIsLogin:(BOOL)login {
    [[NSUserDefaults standardUserDefaults] setBool:login forKey:KIsLoginCache];
}

+ (BOOL)isLogin {
    return [[NSUserDefaults standardUserDefaults] boolForKey:KIsLoginCache];
}

//#pragma mark
//+ (void)setUserAccount:(NSString *)name {
//    [[NSUserDefaults standardUserDefaults] setObject:name forKey:KUserAccount];
//}
//
//+ (NSString *)userAccount {
//    return [[NSUserDefaults standardUserDefaults] stringForKey:KUserAccount];
//}

#pragma mark
+ (void)setUserModel:(UserModel *)model {
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[model dictionary]];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:KUserModelCache];
}

+ (UserModel *)userModel {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:KUserModelCache];
    UserModel *model = [UserModel userManager];
    [model setValuesForKeysWithDictionary:dict];
    
    return model;
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


