//
//  ConnectManager.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectManager : NSObject

+ (instancetype)shareManager;

///login
- (void)loginWithAccount:(NSString *)account password:(NSString *)pwd;

@end
