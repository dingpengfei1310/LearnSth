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

#pragma mark 调试的时候输出日志, 发布的时候不输出

//#ifdef DEBUG
//# define NSLog(...) NSLog(__VA_ARGS__)
//#else
//# define NSLog(...)
//#endif

//#pragma mark
//#ifdef DEBUG
//#define NSLog(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
//#else
//#define NSLog(FORMAT, ...) nil
//#endif

#pragma mark

#define ScreenWidth           [UIScreen mainScreen].bounds.size.width
#define ScreenHeight          [UIScreen mainScreen].bounds.size.height
