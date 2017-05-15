//
//  DownloadModel.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/9.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DownloadState) {
    DownloadStateWaiting = 0,
    DownloadStateRunning,
    DownloadStatePause,
    DownloadStateCompletion,
    DownloadStateFailure
};

@interface DownloadModel : NSObject

@property (nonatomic, copy) NSString *fileUrl;
@property (nonatomic, copy) NSString *fileName;

@property (nonatomic, copy, readonly) NSString *resumePath;//用处：断点下载
@property (nonatomic, copy, readonly) NSString *savePath;//文件保存位置

@property (nonatomic, assign) DownloadState state;
@property (nonatomic, assign) int64_t bytesReceived;
@property (nonatomic, assign) int64_t bytesTotal;

+ (NSDictionary *)loadAllDownload;

+ (void)add:(DownloadModel *)model;
+ (void)update:(DownloadModel *)model;
+ (void)remove:(DownloadModel *)model;

@end
