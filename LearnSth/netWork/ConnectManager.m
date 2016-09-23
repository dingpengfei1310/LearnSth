//
//  ConnectManager.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "ConnectManager.h"
#import "GCDAsyncSocket.h"

/** 交易ip - 模拟 */
static NSString *TRADERIP = @"222.73.119.230";  // 1.0期货测试盘
/** 交易port - 模拟 */
static NSString *TRADERPOTR = @"7003";  // 1.0期货测试盘

@interface ConnectManager() <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *connectSocket;

@end

@implementation ConnectManager

+ (instancetype)shareManager {
    static ConnectManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ConnectManager alloc] init];
    });
    
    return manager;
}

#pragma mark - connect
- (NSError *)connectToHost {
    if (_connectSocket != nil) {
        [_connectSocket setDelegate:nil];
        [_connectSocket disconnect];
        _connectSocket = nil;
    }
    
    _connectSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    NSError *error = nil;
    [_connectSocket connectToHost:TRADERIP onPort:TRADERPOTR.intValue error:&error];
    
    return error;
}

#pragma mark - method
//{(len=37)LOGIN001@M@@C@@@@@&demo000601@666666@}
//{(len=43)LOGIN001@M@@C@10002@@@@@&demo000601@777777@}

- (void)loginWithAccount:(NSString *)account password:(NSString *)pwd {
    [self connectToHost];
    NSString *dataString = [NSString stringWithFormat:@"{(len=37)LOGIN001@M@@C@@@@@&%@@%@@}",account,pwd];
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    [_connectSocket writeData:data withTimeout:-1 tag:60];
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"didConnectToHost: ");
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"didWriteDataWithTag: ");
    [sock readDataWithTimeout:-1 tag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"didReadData: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}


@end


