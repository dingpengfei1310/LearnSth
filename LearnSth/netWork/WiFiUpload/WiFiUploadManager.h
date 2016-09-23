//
//  WiFiUploadManager.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/22.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HTTPServer;

extern NSString * const FileUploadDidStartNotification;
extern NSString * const FileUploadProgressNotification;
extern NSString * const FileUploadDidEndNotification;

@interface WiFiUploadManager : NSObject

@property (nonatomic, strong) HTTPServer *httpServer;
@property (nonatomic, copy) NSString *webPath;
@property (nonatomic, copy) NSString *savePath;

+ (instancetype)shareManager;

- (BOOL)startHTTPServerAtPort:(UInt16)port;

- (BOOL)isServerRunning;
- (void)stopHTTPServer;

- (NSString *)ip;
- (UInt16)port;

- (void)showWiFiPageFrontViewController:(UIViewController *)viewController;

@end
