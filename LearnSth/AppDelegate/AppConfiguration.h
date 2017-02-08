//
//  AppConfiguration.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#ifndef AppConfiguration_h
#define AppConfiguration_h

#endif /* AppConfiguration_h */

#pragma mark
//#ifdef DEBUG
//# define NSLog(...) NSLog(__VA_ARGS__)
//#else
//# define NSLog(...)
//#endif

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"[%s] %s:%d行 %s\n",__TIME__, __PRETTY_FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif

//[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String]

#pragma mark

#define Screen_W              [UIScreen mainScreen].bounds.size.width
#define Screen_H              [UIScreen mainScreen].bounds.size.height

#define kDocumentPath         [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
#define kCachePath            [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]


#pragma mark

#define KBaseBlueColor        [UIColor colorWithRed:21 / 255.0 green:166 / 255.0 blue:246 / 255.0 alpha:1.0]
#define KBaseTextColor        [UIColor grayColor]
#define KBackgroundColor      [UIColor groupTableViewBackgroundColor]
