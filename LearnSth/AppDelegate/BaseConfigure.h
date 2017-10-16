//
//  BaseConfigure.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/6/28.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#ifndef BaseConfigure_h
#define BaseConfigure_h

#pragma mark
//#ifdef DEBUG
//# define NSLog(...) NSLog(__VA_ARGS__)
//#else
//# define NSLog(...)
//#endif

//#ifdef DEBUG
//#define NSLog(FORMAT, ...) fprintf(stderr,"[%s] %s:%d行 %s\n",__TIME__, __PRETTY_FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
//#else
//#define NSLog(FORMAT, ...)
//#endif

//#define DDNSLog(FORMAT, ...) fprintf(stderr,"[%s] %s:%d行 %s\n",__TIME__, __PRETTY_FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

//[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String]
//#ifdef __IPHONE_10_0
//#endif

#define DNSLog(...)           NSLog(__VA_ARGS__)

#pragma mark
#define Screen_W              UIScreen.mainScreen.bounds.size.width
#define Screen_H              UIScreen.mainScreen.bounds.size.height
#define SystemVersion         UIDevice.currentDevice.systemVersion.floatValue

//([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define IPHONE_X              (Screen_H == 812.0 || Screen_W == 812.0)
#define StatusBarH            [[UIApplication sharedApplication] statusBarFrame].size.height
#define TabBarH               (IPHONE_X ? 83.0 : 49.0)
#define NavigationBarH        44.0
#define HomeIndicatorH        34.0

#define KDocumentPath         NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject
#define KCachePath            NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES).firstObject

#define CurrentVersion        [UIDevice currentDevice].systemVersion.floatValue

#pragma mark - color
#define KBaseBlueColor        [UIColor colorWithRed:21/255.0 green:166/255.0 blue:246/255.0 alpha:1.0]
#define KBaseTextColor        [UIColor grayColor]
#define KBackgroundColor      [UIColor groupTableViewBackgroundColor]

#pragma mark - colorNight
#define KCellBackgroundColor  [UIColor darkGrayColor]
//#define KBaseTextColor        [UIColor grayColor]
//#define KBackgroundColor      [UIColor groupTableViewBackgroundColor]

#pragma mark
#define DLocalizedString(key) [[CustomiseTool languageBundle] localizedStringForKey:(key) value:@"" table:nil]

#pragma mark - 通知
#define ChangeNightModel      @"ChangeNightModel"

#endif /* BaseConfigure_h */
