//
//  UserModel.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UserManager.h"
#import <objc/runtime.h>

@interface UserManager ()<NSCopying>

@end

static NSString *KUserManagerCache = @"KUserManagerCache";
static UserManager *userModel;

@implementation UserManager

+ (instancetype)manager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userModel = [[UserManager alloc] init];
    });
    
    return userModel;
}

+ (void)updateUser {
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[[UserManager manager] dictionary]];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:KUserManagerCache];
}

+ (UserManager *)loadUser {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:KUserManagerCache];
    UserManager *user = [UserManager manager];
    [user setValuesForKeysWithDictionary:dict];
    
    return user;
}

#pragma mark
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userModel = [super allocWithZone:zone];
    });
    
    return userModel;
}

- (instancetype)copyWithZone:(NSZone *)zone {
//    UserManager *userModel = [UserManager allocWithZone:zone];
//
//    unsigned int outCount;
//    objc_property_t *propertities = class_copyPropertyList([UserManager class], &outCount);
//    for (int i = 0; i < outCount; i++) {
//        objc_property_t property = propertities[i];
//        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
//
//        [userModel setValue:[self valueForKey:propertyName] forKey:propertyName];
//    }
//
//    return userModel;
    
    return userModel;
}

#pragma mark
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"address"]) {
        AddressModel *model = [[AddressModel alloc] init];
        [model setValuesForKeysWithDictionary:value];
        [super setValue:model forKey:key];
    } else {
        [super setValue:value forKey:key];
    }
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    
    unsigned int outCount;
    objc_property_t *propertities = class_copyPropertyList([UserManager class], &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = propertities[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        if ([propertyName isEqualToString:@"address"]) {
            AddressModel *model = [self valueForKey:propertyName];
            NSDictionary *addressDict = [model dictionary];
            [mutDict setValue:addressDict forKey:propertyName];
        } else {
            [mutDict setValue:[self valueForKey:propertyName] forKey:propertyName];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:mutDict];
}

@end
