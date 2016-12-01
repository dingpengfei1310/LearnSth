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
static NSString *ChooseUserNotification = @"ChooseUserNotification";

@implementation Utils

+ (void)remoAllObjects {
//    NSDictionary* dict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
//    for(NSString * key in [dict allKeys]) {
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
//    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:IsLogin];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserAccount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ChooseUserNotification];
    
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
+ (void)setChooseUserNotification {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ChooseUserNotification];
}

+ (BOOL)haveChooseUserNotification {
    return [[NSUserDefaults standardUserDefaults] boolForKey:ChooseUserNotification];
}

@end


