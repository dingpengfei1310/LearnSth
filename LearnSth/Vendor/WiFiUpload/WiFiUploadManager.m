//
//  WiFiUploadManager.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/22.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "WiFiUploadManager.h"
#import "WiFiUploadViewController.h"

#import "WiFiUploadHTTPConnection.h"
#import "DeviceConfig.h"

#import <HTTPServer.h>

NSString * const WiFiUploadManagerDidStart = @"FileUploadDidStartNotification";
NSString * const WiFiUploadManagerProgress = @"FileUploadProgressNotification";
NSString * const WiFiUploadManagerDidEnd = @"FileUploadDidEndNotification";

@interface WiFiUploadManager ()

@property (nonatomic, strong) NSString *webPath;
@property (nonatomic, strong) NSString *savePath;

@end

@implementation WiFiUploadManager

+ (instancetype)shareManager {
    static WiFiUploadManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WiFiUploadManager alloc] init];
    });
    
    return manager;
}

- (instancetype) init {
    if (self = [super init]) {
        self.webPath = [[NSBundle mainBundle] resourcePath];
        self.savePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    }
    return self;
}

- (NSString *)ip {
    return [DeviceConfig getIPAddress:NO];
}

- (UInt16)port {
    return self.httpServer.port;
}

#pragma mark
- (BOOL)startHTTPServerAtPort:(UInt16)port {
    HTTPServer *server = [HTTPServer new];
    server.port = port;
    self.httpServer = server;
    [self.httpServer setDocumentRoot:self.webPath];
    [self.httpServer setConnectionClass:[WiFiUploadHTTPConnection class]];
    NSError *error = nil;
    [self.httpServer start:&error];
    return error == nil;
}

- (BOOL)startHTTPServer {
    return [self startHTTPServerAtPort:10000];
}

- (BOOL)isServerRunning {
    return self.httpServer.isRunning;
}

- (void)stopHTTPServer {
    [self.httpServer stop];
}

- (void)showWiFiPageViewController:(UIViewController *)viewController {
    WiFiUploadViewController *controller = [[WiFiUploadViewController alloc] init];
    controller.WiFiDismissBlock = ^{
        [viewController dismissViewControllerAnimated:YES completion:nil];
    };
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:controller];
    [viewController presentViewController:nvc animated:YES completion:nil];
}

@end
