//
//  FileManager.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2018/3/13.
//  Copyright © 2018年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

+ (long long)fileSizeAtPath:(NSString *)path;
+ (long long)folderSizeAtPath:(NSString *)path;
+ (void)clearCacheAtPath:(NSString *)path;

+ (long long)systemSize;
+ (long long)systemFreeSize;

@end
