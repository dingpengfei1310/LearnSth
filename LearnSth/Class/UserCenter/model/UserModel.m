//
//  UserModel.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UserModel.h"
#import <objc/runtime.h>

@interface UserModel ()<NSCopying>

@end

@implementation UserModel

- (instancetype)copyWithZone:(NSZone *)zone {
    UserModel *userModel = [UserModel allocWithZone:zone];
    
    unsigned int outCount;
    objc_property_t *propertities = class_copyPropertyList([UserModel class], &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = propertities[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        [userModel setValue:[self valueForKey:propertyName] forKey:propertyName];
    }
    
    return userModel;
}

#pragma mark
+ (instancetype)userManager {
    static UserModel *userModel = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userModel = [[self alloc] init];
    });
    
    return userModel;
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    
    unsigned int outCount;
    objc_property_t *propertities = class_copyPropertyList([UserModel class], &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = propertities[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        [mutDict setValue:[self valueForKey:propertyName] forKey:propertyName];
    }
    
    return mutDict;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

//- (void)setValue:(id)value forKey:(NSString *)key {
//    NSLog(@"%@ - %@",key,[value class]);
//    [super setValue:value forKey:key];
//}

@end