//
//  DownloadManager.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/8.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "DownloadManager.h"

@interface DownloadManager ()<NSURLSessionDownloadDelegate>

@end

@implementation DownloadManager

+ (instancetype)shareManager {
    static DownloadManager *manager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DownloadManager alloc] init];
    });
    
    return manager;
}

- (void)downloadWith:(NSURL *)url {
    NSString * const downloadURLString1 = @"http://baobab.wdjcdn.com/14564977406580.mp4";
//    NSString * const downloadURLString2 = @"http://baobab.wdjcdn.com/1442142801331138639111.mp4";
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                          delegate:self
                                                     delegateQueue:[[NSOperationQueue alloc] init]];
    
    NSURL *ddUrl = [NSURL URLWithString:downloadURLString1];
    NSURLSessionTask *task = [session downloadTaskWithURL:ddUrl completionHandler:^(NSURL * location, NSURLResponse * response, NSError * error) {
        
        NSLog(@"location:%@",location.absoluteString);
    }];
    [task resume];
}

#pragma mark
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"didWriteData:%lld - totalBytesWritten:%lld - totalBytesExpectedToWrite:%lld",bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"didResumeAtOffset:%lld - expectedTotalBytes:%lld",fileOffset,expectedTotalBytes);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"didFinishDownloadingToURL:%@",location.absoluteString);
}

@end
