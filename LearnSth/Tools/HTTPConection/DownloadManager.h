//
//  DownloadManager.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/8.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadManager : NSObject

+ (instancetype)shareManager;

//- (void)downloadWith:(NSURL *)url;

- (void)downloadWith:(NSURL *)url
            progress:(void (^)(int64_t bytesWritten,int64_t bytesExpected))progress
          completion:(void (^)(BOOL isSuccess, NSError *error))completion;

- (void)pause;

@end
