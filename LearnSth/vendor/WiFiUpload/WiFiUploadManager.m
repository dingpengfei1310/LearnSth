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

#include <ifaddrs.h>
#include <arpa/inet.h>

NSString * const FileUploadDidStartNotification = @"SGFileUploadDidStartNotification";
NSString * const FileUploadProgressNotification = @"SGFileUploadProgressNotification";
NSString * const FileUploadDidEndNotification = @"SGFileUploadDidEndNotification";

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
//        self.savePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        self.savePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
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
    [viewController presentViewController:[[UINavigationController alloc] initWithRootViewController:controller] animated:YES completion:nil];
}

#pragma mark
///IPAddress
- (NSString *)deviceIPAdress {
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) {// 0 表示获取成功
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return address;
}


@end



