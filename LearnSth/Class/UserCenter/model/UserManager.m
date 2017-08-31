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
static UserManager *userModel = nil;

static dispatch_once_t managerOnceToken;
static dispatch_once_t allocOnceToken;

@implementation UserManager

+ (instancetype)shareManager {
    dispatch_once(&managerOnceToken, ^{
        userModel = [[UserManager alloc] init];
//        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:KUserManagerCache];
//        [userModel setValuesForKeysWithDictionary:dict];
        
//        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:KUserManagerCache];
//        if (data) {
//            userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//        }
    });
    
    return userModel;
}

+ (void)deallocManager {
    managerOnceToken = 0;
    allocOnceToken = 0;
    userModel = nil;
}

+ (void)updateUser {
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[[UserManager shareManager] dictionary]];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:KUserManagerCache];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userModel];
//    [[NSUserDefaults standardUserDefaults] setObject:data forKey:KUserManagerCache];
}

#pragma mark
//+ (instancetype)allocWithZone:(struct _NSZone *)zone {
//    dispatch_once(&allocOnceToken, ^{
//        userModel = [super allocWithZone:zone];
//    });
//    
//    return userModel;
//}

- (instancetype)copyWithZone:(NSZone *)zone {
    return userModel;
}

//#pragma mark
//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    if (self = [super init]) {
//        unsigned int outCount;
//        objc_property_t *propertities = class_copyPropertyList([UserManager class], &outCount);
//        for (int i = 0; i < outCount; i++) {
//            objc_property_t property = propertities[i];
//            NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
//            
//            if ([propertyName isEqualToString:@"address"]) {
//            } else {
//                [super setValue:[aDecoder decodeObjectForKey:propertyName] forKey:propertyName];
//            }
//        }
//        free(propertities);
//    }
//    return self;
//}
//
//- (void)encodeWithCoder:(NSCoder *)aCoder {
//    unsigned int outCount;
//    objc_property_t *propertities = class_copyPropertyList([UserManager class], &outCount);
//    for (int i = 0; i < outCount; i++) {
//        objc_property_t property = propertities[i];
//        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
//        
//        if ([propertyName isEqualToString:@"address"]) {
//        } else {
//            [aCoder encodeObject:[userModel valueForKey:propertyName] forKey:propertyName];
//        }
//    }
//    free(propertities);
//}

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
            AddressModel *model = [userModel valueForKey:propertyName];
            NSDictionary *addressDict = [model dictionary];
            [mutDict setValue:addressDict forKey:propertyName];
        } else {
            [mutDict setValue:[userModel valueForKey:propertyName] forKey:propertyName];
        }
    }
    free(propertities);
    
    return [NSDictionary dictionaryWithDictionary:mutDict];
}

@end
