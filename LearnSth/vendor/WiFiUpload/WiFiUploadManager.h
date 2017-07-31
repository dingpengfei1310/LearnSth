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
@property (nonatomic, copy) NSString *webPath;
@property (nonatomic, copy) NSString *savePath;

+ (instancetype)shareManager;

- (BOOL)startHTTPServerAtPort:(UInt16)port;
- (BOOL)isServerRunning;
- (void)stopHTTPServer;

- (NSString *)ip;
- (UInt16)port;

- (void)showWiFiPageViewController:(UIViewController *)viewController;

@end
