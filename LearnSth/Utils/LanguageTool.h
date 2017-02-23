//
//  LanguageTool.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/2/20.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DDNSLocalizedGetString(key) \
[[LanguageTool shareInstance] getStringForKey:key withTable:nil]

@interface LanguageTool : NSObject

+ (instancetype)shareInstance;

- (NSString *)currentLanguage;

- (NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table;
- (void)changeLanguage:(NSString *)language;

@end
