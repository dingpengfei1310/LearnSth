//
//  DeviceConfig.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/1/17.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceConfig : NSObject

+ (NSString *)getDeviceName;
+ (NSString *)getDeviceModel;
+ (NSString *)getIPhoneName;

+ (NSString *)getSystemName;
+ (NSString *)getSystemVersion;

+ (NSString *)getUUID;
+ (NSString *)getADIdentifier;

+ (NSString *)getAppVersion;
+ (NSString *)getAppBuildVersion;
+ (NSString *)getAppName;
+ (NSString *)getAppDisplayName;
+ (NSString *)getAppIconName;

+ (NSString *)getIPAddress:(BOOL)preferIPv4;

@end
