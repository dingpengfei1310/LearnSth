//
//  NSString+Tool.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Tool)

/////拼音,系统自带，性能很差
//- (NSString *)pinyin;

///MD5加密
- (NSString *)MD5String;

///手机号码
- (BOOL)validatePhoneNumber;

///密码
- (BOOL)validatePassword;

@end
