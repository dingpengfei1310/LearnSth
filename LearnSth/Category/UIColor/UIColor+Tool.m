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

#pragma mark
+ (UIColor *)colorWithHex:(NSInteger)hex {
    return [UIColor colorWithHex:hex alpha:1.0];
}

+ (UIColor *)colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((hex & 0xFF0000) >> 16) / 255.0f
                           green:((hex & 0xFF00) >> 8) / 255.0f
                            blue:((hex & 0xFF)) / 255.0f
                           alpha:alpha];
}

#pragma mark
+ (UIColor *)colorWithHexString:(NSString *)hex {
    return [UIColor colorWithHexString:hex alpha:1.0];
}

+ (UIColor *)colorWithHexString:(NSString *)hex alpha:(CGFloat)alpha {
    CGFloat red,green,blue;
    NSString *colorString;
    
    if ([hex hasPrefix:@"#"]) {
        colorString = [hex stringByReplacingOccurrencesOfString:@"#" withString:@""];
    } else if ([hex hasPrefix:@"0X"]) {
        colorString = [hex stringByReplacingOccurrencesOfString:@"0X" withString:@""];
    } else if ([hex hasPrefix:@"0x"]) {
        colorString = [hex stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    }
    colorString = [colorString uppercaseString];
    
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = colorComponentFrom(colorString, 0, 1);
            green = colorComponentFrom(colorString, 1, 1);
            blue  = colorComponentFrom(colorString, 2, 1);
            break;
            
        case 4: // #ARGB
            alpha = colorComponentFrom(colorString, 0, 1);
            red   = colorComponentFrom(colorString, 1, 1);
            green = colorComponentFrom(colorString, 2, 1);
            blue  = colorComponentFrom(colorString, 3, 1);
            break;
            
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = colorComponentFrom(colorString, 0, 2);
            green = colorComponentFrom(colorString, 2, 2);
            blue  = colorComponentFrom(colorString, 4, 2);
            break;
            
        case 8: // #AARRGGBB
            alpha = colorComponentFrom(colorString, 0, 2);
            red   = colorComponentFrom(colorString, 2, 2);
            green = colorComponentFrom(colorString, 4, 2);
            blue  = colorComponentFrom(colorString, 6, 2);
            break;
            ;
        default:
            return nil;
    }
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

CGFloat colorComponentFrom(NSString *string, NSUInteger start, NSUInteger length) {
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

@end
