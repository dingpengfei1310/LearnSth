//
//  DownloadManager.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/8.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "DownloadManager.h"

@interface DownloadManager ()<NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSURL *downloadUrl;

@property (nonatomic, copy) void (^DownloadState)(NSURLSessionTaskState state);
@property (nonatomic, copy) void (^DownloadProgress)(int64_t bytesWritten,int64_t bytesExpected);
@property (nonatomic, copy) void (^DownloadCompletion)(BOOL isSuccess, NSError *error);

@end

static NSString *ResumeName = @"resumeFile-";

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
    _downloadUrl = url;
    
    if (_downloadTask.state != NSURLSessionTaskStateCompleted) {
//        NSString *filePath = [KDocumentPath stringByAppendingPathComponent:url.lastPathComponent];
//        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
//        uint64_t length =  [fileAttributes[NSFileSize] integerValue];
//        NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:_downloadUrl];
//        [requestM setValue:[NSString stringWithFormat:@"bytes=%lld-", (long long)length] forHTTPHeaderField:@"Range"];
//        _downloadTask = [session downloadTaskWithRequest:requestM];
    }
    
    
    
    
//    if (_dataTask.state != NSURLSessionTaskStateCompleted) {
//        NSString *filePath = [KDocumentPath stringByAppendingPathComponent:url.lastPathComponent];
//        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
//        uint64_t length =  [fileAttributes[NSFileSize] integerValue];
//        
//        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
//                                                              delegate:self
//                                                         delegateQueue:[[NSOperationQueue alloc] init]];
//        
//        NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:_downloadUrl];
//        [requestM setValue:[NSString stringWithFormat:@"bytes=%lld-", (long long)length] forHTTPHeaderField:@"Range"];
//        _dataTask = [session dataTaskWithRequest:requestM];
//        [_dataTask resume];
//    }
}

- (void)downloadWith:(NSURL *)url
               state:(void (^)(NSURLSessionTaskState state))state
            progress:(void (^)(int64_t, int64_t))progress
          completion:(void (^)(BOOL, NSError *))completion {
    
    if (_downloadUrl != url) {
        [self pause];
        _downloadUrl = url;
    }
    
    self.DownloadState = state;
    self.DownloadProgress = progress;
    self.DownloadCompletion = completion;
    
    NSString *str = [NSString stringWithFormat:@"%@%@",ResumeName,_downloadUrl.lastPathComponent];
    NSString *filePath = [KDocumentPath stringByAppendingPathComponent:str];
    NSData *resumeData = [NSData dataWithContentsOfFile:filePath];
    
    if (!resumeData) {
        _downloadTask = [self.session downloadTaskWithURL:_downloadUrl];
    } else {
        _downloadTask = [self.session downloadTaskWithResumeData:resumeData];
    }
    
    [_downloadTask resume];
}

- (void)pause {
    if (!_downloadUrl) {
        return;
    }
    [_downloadTask cancelByProducingResumeData:^(NSData * resumeData) {
        NSString *str = [NSString stringWithFormat:@"%@%@",ResumeName,_downloadUrl.lastPathComponent];
        NSString *filePath = [KDocumentPath stringByAppendingPathComponent:str];
        [resumeData writeToFile:filePath atomically:YES];
        
        if (self.DownloadState) {
            self.DownloadState(NSURLSessionTaskStateCanceling);
        }
    }];
}

- (BOOL)isRunning {
    return (_downloadTask && _downloadTask.state == NSURLSessionTaskStateRunning);
}

#pragma mark NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSLog(@"didReceiveData:%@",@"data");
}

- (void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSLog(@"completionHandler:%@",@"response");
    completionHandler(NSURLSessionResponseAllow);
}

#pragma mark NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"didFinishDownloadingToURL:%@",location.absoluteString);
    
    NSString *str = [NSString stringWithFormat:@"%@%@",ResumeName,_downloadUrl.lastPathComponent];
    unlink([str UTF8String]);
    
    NSError *error;
    NSString *filePath = [KDocumentPath stringByAppendingPathComponent:_downloadUrl.lastPathComponent];
    unlink([filePath UTF8String]);
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:fileUrl error:&error];
    
    NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithDictionary:[CustomiseTool downloadFile]];
    [dictM removeObjectForKey:_downloadUrl.absoluteString];
    [CustomiseTool setDownloadFile:dictM];
    
    if (self.DownloadCompletion) {
        self.DownloadCompletion(!error,error);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
//    NSLog(@"didWriteData:%lld - totalBytesWritten:%lld - totalBytesExpectedToWrite:%lld",bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
    if (self.DownloadProgress) {
        self.DownloadProgress(totalBytesWritten,totalBytesExpectedToWrite);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
//    NSLog(@"didResumeAtOffset:%lld - expectedTotalBytes:%lld",fileOffset,expectedTotalBytes);
}

#pragma mark NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
//    if (error) {
//        NSData *data = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
//    }
    NSLog(@"didCompleteWithError");
}

#pragma mark
- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"DownloadManager"];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _session;
}

@end
