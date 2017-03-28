//
//  DownloadManager.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/8.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadModel.h"

@interface DownloadManager : NSObject

+ (instancetype)shareManager;

- (BOOL)isDownloading;
- (void)pauseWithUrl:(NSURL *)url;

- (void)downloadWithUrl:(NSURL *)url
                  state:(void (^)(DownloadState state))state
               progress:(void (^)(int64_t bytesWritten,int64_t bytesTotal))progress
             completion:(void (^)(BOOL isSuccess, NSError *error))completion;

@end
