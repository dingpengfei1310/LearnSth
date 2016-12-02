//
//  UIColor+Tool.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/2.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Tool)

+ (UIColor *)colorWithHex:(NSInteger)hex;
+ (UIColor *)colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha;

@end
