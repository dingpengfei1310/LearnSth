//
//  DownloadManager.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/8.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DownloadModel;
@interface DownloadManager : NSObject

+ (instancetype)shareManager;

- (void)downloadWithUrl:(NSURL *)url
                  state:(void (^)(NSURLSessionTaskState state))state
               progress:(void (^)(int64_t bytesWritten,int64_t bytesTotal))progress
             completion:(void (^)(BOOL isSuccess, NSError *error))completion;

//- (void)downloadWithModel:(NSURL *)url
//                    state:(void (^)(NSURLSessionTaskState state))state
//                 progress:(void (^)(int64_t bytesWritten,int64_t bytesTotal))progress
//               completion:(void (^)(BOOL isSuccess, NSError *error))completion;

- (void)pause;
- (BOOL)isRunning;

@end
