//
//  ADModel.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/11.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "ADModel.h"
#import <objc/runtime.h>

@interface ADModel ()<NSCopying>

@end

@implementation ADModel

- (instancetype)copyWithZone:(NSZone *)zone {
    ADModel *adModle = [ADModel allocWithZone:zone];
    
    unsigned int outCount;
    objc_property_t *propertities = class_copyPropertyList([ADModel class], &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = propertities[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        [adModle setValue:[self valueForKey:propertyName] forKey:propertyName];
    }
    free(propertities);
    return adModle;
}

#pragma mark
+ (NSArray<ADModel *> *)adWithArray:(NSArray *)array {
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:array.count];
    
    for (NSDictionary *dict in array) {
        ADModel *adModel = [[ADModel alloc] init];
        [adModel setValuesForKeysWithDictionary:dict];
        [tempArray addObject:adModel];
    }
    
    return [NSArray arrayWithArray:tempArray];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end
