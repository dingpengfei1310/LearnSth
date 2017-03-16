//
//  DownloadManager.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/8.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "DownloadManager.h"
#import "DownloadModel.h"

typedef NS_ENUM(NSInteger,SessionTaskType) {
    SessionTaskTypeDownload = 0,
    SessionTaskTypeData
};

@interface DownloadManager ()<NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURL *taskUrl;

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

@property (nonatomic, strong) DownloadModel *currentModel;

@property (nonatomic, copy) void (^DownloadState)(DownloadState state);
@property (nonatomic, copy) void (^DownloadProgress)(int64_t bytesWritten,int64_t bytesExpected);
@property (nonatomic, copy) void (^DownloadCompletion)(BOOL isSuccess, NSError *error);

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) SessionTaskType downloadType;

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

#pragma mark
- (void)downloadWithUrl:(NSURL *)url
                  state:(void (^)(DownloadState state))state
               progress:(void (^)(int64_t bytesWritten,int64_t bytesTotal))progress
             completion:(void (^)(BOOL isSuccess, NSError *error))completion {
    
    if (!url) {
        state(DownloadStateFailure);
        return;
    }
    
    //正在下载
    if (self.isDownloading) {
        
        //当前的URL正在下载
        if ([self.taskUrl isEqual:url]) {
            
            self.DownloadState = state;
            self.DownloadProgress = progress;
            self.DownloadCompletion = completion;
        }
        
        return;
    }
    
    if (![self.taskUrl isEqual:url]) {
        self.taskUrl = url;
        
        NSDictionary *allDownLoad = [DownloadModel loadAllDownload];
        self.currentModel = allDownLoad[self.taskUrl.absoluteString];
    }
    
    self.DownloadState = state;
    self.DownloadProgress = progress;
    self.DownloadCompletion = completion;
    
    [self dataTaskWithUrl:url state:state progress:progress completion:completion];
}

- (void)dataTaskWithUrl:(NSURL *)url
                  state:(void (^)(DownloadState state))state
               progress:(void (^)(int64_t bytesWritten,int64_t bytesTotal))progress
             completion:(void (^)(BOOL isSuccess, NSError *error))completion {
    
    self.downloadType = SessionTaskTypeData;
    
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:self.taskUrl];
    [requestM setValue:[NSString stringWithFormat:@"bytes=%ld-",[self hasDownloadLength]] forHTTPHeaderField:@"Range"];
    self.dataTask = [self.session dataTaskWithRequest:requestM];
    
    [self.dataTask resume];
    [self.timer fire];
}

- (void)downloadTaskWithUrl:(NSURL *)url
                      state:(void (^)(DownloadState state))state
                   progress:(void (^)(int64_t bytesWritten,int64_t bytesTotal))progress
                 completion:(void (^)(BOOL isSuccess, NSError *error))completion {
    
    self.downloadType = SessionTaskTypeDownload;
    
    NSData *resumeData = [NSData dataWithContentsOfFile:self.currentModel.resumePath];
    if (!resumeData) {
        self.downloadTask = [self.session downloadTaskWithURL:self.taskUrl];
    } else {
        self.downloadTask = [self.session downloadTaskWithResumeData:resumeData];
    }
    
    [self.downloadTask resume];
    [self.timer fire];
}

- (BOOL)isDownloading {
    BOOL dataTaskRuning = (self.dataTask && self.dataTask.state == NSURLSessionTaskStateRunning);
    BOOL downloadTaskRuning = (self.downloadTask && self.downloadTask.state == NSURLSessionTaskStateRunning);
    
    return (dataTaskRuning || downloadTaskRuning);
}

- (void)pauseWithUrl:(NSURL *)url {
    if (!self.isDownloading || ![url isEqual:self.taskUrl]) {
        return;
    }
    
    //SessionTaskTypeData
    if (self.downloadType == SessionTaskTypeData) {
        
        [self.dataTask cancel];
        
        [self.timer invalidate];
        self.timer = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.DownloadState) {
                self.DownloadState(DownloadStatePause);
            }
        });
        
        return;
    }
    
    //SessionTaskTypeData
    //正在下载，并且URL＝_downloadUrl,才会取消下载
    [self.downloadTask cancelByProducingResumeData:^(NSData * resumeData) {
        
        [self.timer invalidate];
        self.timer = nil;
        
        [resumeData writeToFile:self.currentModel.resumePath atomically:YES];
        
        self.currentModel.state = DownloadStatePause;
        [DownloadModel update:self.currentModel];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.DownloadState) {
                self.DownloadState(DownloadStatePause);
            }
        });
    }];
    
}

#pragma mark  - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
//    NSLog(@"didReceiveData:%@",@"data");
    
    self.currentModel.bytesReceived = self.currentModel.bytesReceived + data.length;
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.currentModel.savePath];
    [fileHandle seekToEndOfFile];  //将节点跳到文件的末尾
    [fileHandle writeData:data]; //追加写入数据
    [fileHandle closeFile];
}

- (void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    NSInteger thisTotalLength = response.expectedContentLength; // [response.allHeaderFields[@"Content-Length"] integerValue]
    NSInteger hasDownloadLength = [self hasDownloadLength];
    if (hasDownloadLength == 0) {
        [[NSFileManager defaultManager] createFileAtPath:self.currentModel.savePath contents:nil attributes:nil];
    }
    NSInteger totalLength = thisTotalLength + hasDownloadLength;
    
    _currentModel.bytesReceived = hasDownloadLength;
    _currentModel.bytesTotal = totalLength;
    _currentModel.state = DownloadStateRunning;
    [DownloadModel update:_currentModel];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (NSInteger)hasDownloadLength {
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.currentModel.savePath error:nil];
    return [fileAttributes[NSFileSize] integerValue];
}

#pragma mark  - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"didFinishDownloadingToURL:%@",location.absoluteString);
    
    unlink([self.currentModel.resumePath UTF8String]);
    
    NSError *error;
//    unlink([self.currentModel.savePath UTF8String]);
    if (self.currentModel.savePath) {
        NSURL *fileUrl = [NSURL fileURLWithPath:self.currentModel.savePath];
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:fileUrl error:&error];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    _currentModel.bytesReceived = totalBytesWritten;
    _currentModel.bytesTotal = totalBytesExpectedToWrite;
    _currentModel.state = DownloadStateRunning;
    
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
    NSLog(@"didCompleteWithError");
    
    [self.timer invalidate];
    self.timer = nil;
    
    if (error) {
        if ([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"cancelled"]) {
            return;
        }
        if (self.DownloadState) {
            self.DownloadState(DownloadStateFailure);
        }
    } else {
        
        self.currentModel.state = DownloadStateCompletion;
        [DownloadModel update:self.currentModel];
        
        self.currentModel = nil;
        self.taskUrl = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.DownloadCompletion) {
                self.DownloadCompletion(!error,error);
            }
        });
    }
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
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * timer) {
            
            [DownloadModel update:_currentModel];
            if (self.DownloadProgress) {
                self.DownloadProgress(_currentModel.bytesReceived,_currentModel.bytesTotal);
            }
            
        }];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

@end
