//
//  AddressModel.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/1/3.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "AddressModel.h"
#import <objc/runtime.h>

@implementation AddressModel

- (NSDictionary *)dictionary {
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    
    unsigned int outCount;
    objc_property_t *propertities = class_copyPropertyList([AddressModel class], &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = propertities[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        [mutDict setValue:[self valueForKey:propertyName] forKey:propertyName];
    }
    
    return [NSDictionary dictionaryWithDictionary:mutDict];
}

@end
