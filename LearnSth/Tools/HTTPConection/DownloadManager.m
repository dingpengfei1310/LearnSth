//
//  DownloadManager.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/8.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "DownloadManager.h"

@implementation DownloadManager

+ (instancetype)shareManager {
    static DownloadManager *manager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DownloadManager alloc] init];
    });
    
    return manager;
}



@end
