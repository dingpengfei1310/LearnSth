//
//  DeviceConfig.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/1/17.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceConfig : NSObject

+ (NSString *)getDeviceName;
+ (NSString *)getDeviceModel;
+ (NSString *)getIPhoneName;

+ (NSString *)getSystemName;
+ (NSString *)getSystemVersion;

+ (NSString *)getUUID;
+ (NSString *)getADIdentifier;

+ (NSString *)getAppVersion;
+ (NSString *)getAppName;
+ (NSString *)getAppDisplayName;

+ (NSString *)getIPAddresses;

@end
