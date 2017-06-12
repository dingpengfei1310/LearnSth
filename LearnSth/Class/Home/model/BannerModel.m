//
//  BannerModel.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/11.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "BannerModel.h"
#import <objc/runtime.h>

@interface BannerModel ()<NSCopying>

@end

static NSString *KBannerCache = @"KBannerCache";

@implementation BannerModel

- (instancetype)copyWithZone:(NSZone *)zone {
    BannerModel *adModle = [BannerModel allocWithZone:zone];
    
    unsigned int outCount;
    objc_property_t *propertities = class_copyPropertyList([BannerModel class], &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = propertities[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        [adModle setValue:[self valueForKey:propertyName] forKey:propertyName];
    }
    free(propertities);
    return adModle;
}

#pragma mark
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        unsigned int outCount;
        objc_property_t *propertities = class_copyPropertyList([BannerModel class], &outCount);
        for (int i = 0; i < outCount; i++) {
            objc_property_t property = propertities[i];
            NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];

            [super setValue:[aDecoder decodeObjectForKey:propertyName] forKey:propertyName];
        }
        free(propertities);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int outCount;
    objc_property_t *propertities = class_copyPropertyList([BannerModel class], &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = propertities[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];

        [aCoder encodeObject:[self valueForKey:propertyName] forKey:propertyName];
    }
    free(propertities);
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
}

#pragma mark
+ (NSArray *)bannerWithArray:(NSArray *)array {
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:array.count];
    
    for (NSDictionary *dict in array) {
        BannerModel *adModel = [[BannerModel alloc] init];
        [adModel setValuesForKeysWithDictionary:dict];
        [tempArray addObject:adModel];
    }
    return [NSArray arrayWithArray:tempArray];
}

+ (void)cacheWithBanners:(NSArray *)banners {
    if (banners.count > 0) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:banners];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:KBannerCache];
    }
}

+ (NSArray *)bannerWithCacheArray {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:KBannerCache];
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

@end
