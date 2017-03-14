//
//  DownloadManager.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/8.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "DownloadManager.h"
#import "DownloadModel.h"

@interface DownloadManager ()<NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSURL *downloadUrl;

@property (nonatomic, strong) DownloadModel *currentModel;

@property (nonatomic, copy) void (^DownloadState)(NSURLSessionTaskState state);
@property (nonatomic, copy) void (^DownloadProgress)(int64_t bytesWritten,int64_t bytesExpected);
@property (nonatomic, copy) void (^DownloadCompletion)(BOOL isSuccess, NSError *error);

@property (nonatomic, strong) NSTimer *timer;

@end

static DownloadManager *manager = nil;

@implementation DownloadManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DownloadManager alloc] init];
    });
    
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];
    });
    
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)downloadWithUrl:(NSURL *)url
                  state:(void (^)(NSURLSessionTaskState state))state
               progress:(void (^)(int64_t bytesWritten,int64_t bytesTotal))progress
             completion:(void (^)(BOOL isSuccess, NSError *error))completion {
    if (_downloadUrl != url) {
        [self pause];
        _downloadUrl = url;
        
        NSDictionary *allDownLoad = [DownloadModel loadAllDownload];
        _currentModel = allDownLoad[_downloadUrl.absoluteString];
    }
    
    self.DownloadState = state;
    self.DownloadProgress = progress;
    self.DownloadCompletion = completion;
    
    if (_downloadTask && _downloadTask.state == NSURLSessionTaskStateRunning) {
        return;
    }
    
    NSString *filePath = [KDocumentPath stringByAppendingPathComponent:_currentModel.resumePath];
    NSData *resumeData = [NSData dataWithContentsOfFile:filePath];
    
    if (!resumeData) {
        _downloadTask = [self.session downloadTaskWithURL:_downloadUrl];
    } else {
        _downloadTask = [self.session downloadTaskWithResumeData:resumeData];
    }
    [_downloadTask resume];
    
    [self.timer fire];
}

//- (void)downloadWithModel:(NSURL *)url
//                    state:(void (^)(NSURLSessionTaskState state))state
//                 progress:(void (^)(int64_t bytesWritten,int64_t bytesTotal))progress
//               completion:(void (^)(BOOL isSuccess, NSError *error))completion {
//    
//}

- (void)pause {
    if (!_downloadUrl) {
        return;
    }
    
    [_downloadTask cancelByProducingResumeData:^(NSData * resumeData) {
        
        [self.timer invalidate];
        self.timer = nil;
        NSString *filePath = [KDocumentPath stringByAppendingPathComponent:_currentModel.resumePath];
        [resumeData writeToFile:filePath atomically:YES];
        
        _currentModel.state = DownloadStatePause;
        [DownloadModel update:_currentModel];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.DownloadState) {
                self.DownloadState(NSURLSessionTaskStateCanceling);
            }
        });
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
    
    [self.timer invalidate];
    self.timer = nil;
    
    NSString *resumePath = [KDocumentPath stringByAppendingPathComponent:_currentModel.resumePath];
    unlink([resumePath UTF8String]);
    
    NSError *error;
    NSString *filePath = [KDocumentPath stringByAppendingPathComponent:_currentModel.fileName];
    unlink([filePath UTF8String]);
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:fileUrl error:&error];
    
    [DownloadModel remove:_currentModel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.DownloadCompletion) {
            self.DownloadCompletion(!error,error);
        }
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    _currentModel.bytesReceived = totalBytesWritten;
    _currentModel.bytesTotal = totalBytesExpectedToWrite;
    _currentModel.state = DownloadStateRunning;
    [DownloadModel update:_currentModel];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (self.DownloadProgress) {
//            self.DownloadProgress(totalBytesWritten,totalBytesExpectedToWrite);
//        }
//    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
}

#pragma mark NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
//    if (error) {
////        NSURLSessionDownloadTaskResumeData
//        NSLog(@"didCompleteWithError:__%@",error);
//    }
}

#pragma mark
- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"DownloadManager"];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _session;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
            if (self.DownloadProgress) {
                self.DownloadProgress(_currentModel.bytesReceived,_currentModel.bytesTotal);
            }
        }];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

@end
