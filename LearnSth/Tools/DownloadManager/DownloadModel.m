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

static NSString *const KDownloadCachePlist = @"DownloadCache.plist";
static NSString *const KDownloadDirectory = @"download";

@implementation DownloadModel

- (NSString *)resumePath {
    return [[DownloadModel directoryPath] stringByAppendingPathComponent:[self.fileUrl MD5String]];
}

- (NSString *)savePath {
    NSString *path = [NSString stringWithFormat:@"%@.mp4",self.fileName];
    return [[DownloadModel directoryPath] stringByAppendingPathComponent:path];
}

#pragma mark
+ (NSDictionary *)loadAllDownload {
    NSDictionary *downloadDict = [NSDictionary dictionaryWithContentsOfFile:[DownloadModel plistPath]];
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    
    for (NSString *key in downloadDict.allKeys) {
        NSDictionary *dict = downloadDict[key];
        DownloadModel *model = [[DownloadModel alloc] init];
        [model setValuesForKeysWithDictionary:dict];
        [dictM setObject:model forKey:key];
    }
    
    return [NSDictionary dictionaryWithDictionary:dictM];
}

+ (void)add:(DownloadModel *)model {
    NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithContentsOfFile:[DownloadModel plistPath]] ?:[NSMutableDictionary dictionary];
    
    if (![dictM.allKeys containsObject:model.fileUrl]) {
        [dictM setObject:[model dictionary] forKey:model.fileUrl];
        [DownloadModel setDownload:dictM];
    }
}

+ (void)update:(DownloadModel *)model {
    NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithContentsOfFile:[DownloadModel plistPath]];
    
    if ([dictM.allKeys containsObject:model.fileUrl]) {
        [dictM setObject:[model dictionary] forKey:model.fileUrl];
        [DownloadModel setDownload:dictM];
    }
}

+ (void)remove:(DownloadModel *)model {
    NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithContentsOfFile:[DownloadModel plistPath]];
    
    if ([dictM.allKeys containsObject:model.fileUrl]) {
        [dictM removeObjectForKey:model.fileUrl];
        [DownloadModel setDownload:dictM];
    }
}

+ (void)setDownload:(NSDictionary *)dict {
    [dict writeToFile:[DownloadModel plistPath] atomically:YES];
}

+ (NSString *)directoryPath {
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject;
    NSString *directoryPath = [documentPath stringByAppendingPathComponent:KDownloadDirectory];
    
    BOOL flag;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (!([fileManager fileExistsAtPath:directoryPath isDirectory:&flag] && flag)) {
        [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return directoryPath;
}

+ (NSString *)plistPath {
    return [[DownloadModel directoryPath] stringByAppendingPathComponent:KDownloadCachePlist];
}

#pragma mark
- (NSDictionary *)dictionary {
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    
    unsigned int outCount;
    objc_property_t *propertities = class_copyPropertyList([DownloadModel class], &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = propertities[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        [mutDict setValue:[self valueForKey:propertyName] forKey:propertyName];
    }
    free(propertities);
    return [NSDictionary dictionaryWithDictionary:mutDict];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
}

@end
