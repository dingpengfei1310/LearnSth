//
//  WiFiUploadManager.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/22.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTTPServer;

extern NSString * const WiFiUploadManagerDidStart;
extern NSString * const WiFiUploadManagerProgress;
extern NSString * const WiFiUploadManagerDidEnd;

@interface WiFiUploadManager : NSObject

@property (nonatomic, strong) HTTPServer *httpServer;
@property (nonatomic, strong, readonly) NSString *webPath;
@property (nonatomic, strong, readonly) NSString *savePath;

+ (instancetype)shareManager;
- (NSString *)ip;
- (UInt16)port;

//- (BOOL)startHTTPServerAtPort:(UInt16)port;
///启动
- (BOOL)startHTTPServer;
- (BOOL)isServerRunning;
///停止
- (void)stopHTTPServer;


- (void)showWiFiPageViewController:(UIViewController *)viewController;

@end
