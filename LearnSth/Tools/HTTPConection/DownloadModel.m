//
//  DownloadModel.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/9.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "DownloadModel.h"
#import "NSString+Tool.h"
#import <objc/runtime.h>

static NSString *KDownloadCache = @"DownloadCache";

@implementation DownloadModel

- (NSString *)resumePath {
    if (self.fileUrl) {
        return [self.fileUrl MD5String];
    }
    return @"";
}

#pragma mark
+ (NSDictionary *)loadAllDownload {
    NSDictionary *downloadDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:KDownloadCache];
    NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithDictionary:downloadDict];
    
    for (NSString *key in downloadDict.allKeys) {
        NSDictionary *dict = downloadDict[key];
        DownloadModel *model = [[DownloadModel alloc] init];
        [model setValuesForKeysWithDictionary:dict];
        [dictM setObject:model forKey:key];
    }
    
    return [NSDictionary dictionaryWithDictionary:dictM];
}

+ (void)add:(DownloadModel *)model {
    NSDictionary *downloadDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:KDownloadCache];
    NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithDictionary:downloadDict];
    
    if (![dictM.allKeys containsObject:model.fileUrl]) {
        [dictM setObject:[model dictionary] forKey:model.fileUrl];
        [DownloadModel setDownload:dictM];
    }
}

+ (void)update:(DownloadModel *)model {
    NSDictionary *downloadDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:KDownloadCache];
    NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithDictionary:downloadDict];
    
    if ([dictM.allKeys containsObject:model.fileUrl]) {
        [dictM setObject:[model dictionary] forKey:model.fileUrl];
        [DownloadModel setDownload:dictM];
    }
}

+ (void)remove:(DownloadModel *)model {
    NSDictionary *downloadDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:KDownloadCache];
    NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithDictionary:downloadDict];
    
    if ([dictM.allKeys containsObject:model.fileUrl]) {
        [dictM removeObjectForKey:model.fileUrl];
        [DownloadModel setDownload:dictM];
    }
}

#pragma mark
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
}

+ (void)setDownload:(NSDictionary *)dict {
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:KDownloadCache];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    
    unsigned int outCount;
    objc_property_t *propertities = class_copyPropertyList([DownloadModel class], &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = propertities[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        [mutDict setValue:[self valueForKey:propertyName] forKey:propertyName];
    }
    
    return [NSDictionary dictionaryWithDictionary:mutDict];
}

@end
