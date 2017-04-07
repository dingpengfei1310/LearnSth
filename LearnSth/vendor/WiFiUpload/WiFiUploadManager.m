//
//  WiFiUploadManager.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/22.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "WiFiUploadManager.h"
#import "WiFiUploadViewController.h"

#import "HTTPServer.h"
#import "WiFiUploadHTTPConnection.h"
#import "DeviceConfig.h"

NSString * const FileUploadDidStartNotification = @"SGFileUploadDidStartNotification";
NSString * const FileUploadProgressNotification = @"SGFileUploadProgressNotification";
NSString * const FileUploadDidEndNotification = @"FileUploadDidEndNotification";

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
        self.savePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];;
    }
    return self;
}

- (NSString *)ip {
    return [self deviceIPAdress];
}
- (UInt16)port {
    return self.httpServer.port;
}

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

#pragma mark
///IPAddress
- (NSString *)deviceIPAdress {
    return [DeviceConfig getIPAddress:NO];
}

@end
