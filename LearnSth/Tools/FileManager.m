//
//  FileManager.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2018/3/13.
//  Copyright © 2018年 丁鹏飞. All rights reserved.
//

#import "FileManager.h"
#import <sys/stat.h>

@implementation FileManager

+ (long long)fileSizeAtPath:(NSString *)path {
    //co方法，速度慢
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if ([fileManager fileExistsAtPath:path]) {
//        long long size = [fileManager attributesOfItemAtPath:path error:nil].fileSize;
//        return size;
//    }
    
    //速度快
    struct stat st;
    if (lstat([path cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0) {
        return st.st_size;
    }
    return 0;
}

+ (long long)folderSizeAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDirectory;
    BOOL isExists= [fileManager fileExistsAtPath:path isDirectory:&isDirectory];
    if (isExists) {
        long long folderSize = 0;
        
        if (isDirectory) {
            NSArray *childerFiles = [fileManager subpathsAtPath:path];
            for (NSString *fileName in childerFiles) {
                NSString *fileAbsolutePath = [path stringByAppendingPathComponent:fileName];
                folderSize += [self fileSizeAtPath:fileAbsolutePath];
            }
            return folderSize;
        } else {
            return [self fileSizeAtPath:path];
        }
    }
    
    return 0.0;
}

+ (void)clearCacheAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles = [fileManager contentsOfDirectoryAtPath:path error:NULL];
        
        for (NSString *fileName in childerFiles) {
            NSString *fileAbsolutePath = [path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:fileAbsolutePath error:NULL];
        }
    }
}

#pragma mark
+ (long long)systemSize {
    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:NULL];
    NSNumber *systemNum = [dict objectForKey:NSFileSystemSize];
    long long systemSize = [systemNum unsignedLongLongValue] / 1024.0;
    return systemSize;
}

+ (long long)systemFreeSize {
    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:NULL];
    NSNumber *freeNum = [dict objectForKey:NSFileSystemFreeSize];
    long long freeSize = [freeNum unsignedLongLongValue] / 1024.0;
    return freeSize;
    
}

@end
