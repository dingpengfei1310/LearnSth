//
//  DownloadManager.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/8.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "DownloadManager.h"

@interface DownloadManager ()<NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionDownloadDelegate>

//@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSURL *downloadUrl;

@property (nonatomic, copy) void (^DownloadProgress)(int64_t bytesWritten,int64_t bytesExpected);
@property (nonatomic, copy) void (^DownloadCompletion)(BOOL isSuccess, NSError *error);

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

- (void)downloadWith:(NSURL *)url progress:(void (^)(int64_t, int64_t))progress completion:(void (^)(BOOL, NSError *))completion {
    _downloadUrl = url;
    self.DownloadProgress = progress;
    self.DownloadCompletion = completion;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"DownloadManager"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    
    NSString *filePath = [KDocumentPath stringByAppendingPathComponent:_downloadUrl.lastPathComponent];
    NSData *resumeData = [NSData dataWithContentsOfFile:filePath];
    if (!resumeData) {
        _downloadTask = [session downloadTaskWithURL:_downloadUrl];
    } else {
        _downloadTask = [session downloadTaskWithResumeData:resumeData];
    }
    
    [_downloadTask resume];
}

- (void)pause {
    [_downloadTask cancelByProducingResumeData:^(NSData * resumeData) {
        NSString *filePath = [KDocumentPath stringByAppendingPathComponent:_downloadUrl.lastPathComponent];
        [resumeData writeToFile:filePath atomically:YES];
    }];
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
    
    NSError *error;
    NSString *filePath = [KDocumentPath stringByAppendingPathComponent:_downloadUrl.lastPathComponent];
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
    NSLog(@"didWriteData:%lld - totalBytesWritten:%lld - totalBytesExpectedToWrite:%lld",bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
    if (self.DownloadProgress) {
        self.DownloadProgress(totalBytesWritten,totalBytesExpectedToWrite);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"didResumeAtOffset:%lld - expectedTotalBytes:%lld",fileOffset,expectedTotalBytes);
}

#pragma mark NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"didCompleteWithError:%@",error);
    
}

@end
