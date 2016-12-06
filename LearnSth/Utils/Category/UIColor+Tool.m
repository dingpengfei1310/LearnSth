//
//  UIColor+Tool.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/2.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UIColor+Tool.h"

@implementation UIColor (Tool)

+ (UIColor *)r:(CGFloat)r g:(CGFloat)g b:(CGFloat)b {
    return [UIColor colorWithRed:r / 255.0
                           green:g / 255.0
                            blue:b / 255.0
                           alpha:1.0];
}

+ (UIColor *)r:(CGFloat)r g:(CGFloat)g b:(CGFloat)b alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:r / 255.0
                           green:g / 255.0
                            blue:b / 255.0
                           alpha:alpha];
}


+ (UIColor *)colorWithHex:(NSInteger)hex {
    return [self colorWithHex:hex alpha:1.0];
}

+ (UIColor *)colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((hex & 0xFF0000) >> 16) / 255.0f
                           green:((hex & 0xFF00) >> 8) / 255.0f
                            blue:((hex & 0xFF)) / 255.0f
                           alpha:alpha];
}


@end
