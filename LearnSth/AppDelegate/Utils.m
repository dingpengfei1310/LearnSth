//
//  Utils.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/31.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "Utils.h"

static NSString *IsLogin = @"userLogin";
static NSString *Nickname = @"nickname";

@implementation Utils

+ (void)remoAllObjects {
//    NSDictionary* dict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
//    for(NSString * key in [dict allKeys]) {
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
//    }
    
    
}

#pragma mark
+ (void)setIsLogin:(BOOL)login {
    [[NSUserDefaults standardUserDefaults] setBool:login forKey:IsLogin];
}

+ (BOOL)isLogin {
    return [[NSUserDefaults standardUserDefaults] boolForKey:IsLogin];
}


#pragma mark
+ (void)setUserNickname:(NSString *)name {
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:Nickname];
}

+ (NSString *)userNickname {
    return [[NSUserDefaults standardUserDefaults] stringForKey:Nickname];
}

@end
