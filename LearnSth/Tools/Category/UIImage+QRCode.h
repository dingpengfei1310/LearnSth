//
//  UIImage+QRCode.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/25.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QRCode)

+ (UIImage *)imageWithText:(NSString *)text;
+ (UIImage *)imageWithText:(NSString *)text size:(CGFloat)size;

+ (UIImage *)imageWithText:(NSString *)text size:(CGFloat)size watermark:(UIImage *)watermark;
+ (UIImage *)imageWithText:(NSString *)text size:(CGFloat)size frontColor:(CIColor *)fColor backColor:(CIColor *)bColor;
+ (UIImage *)imageWithText:(NSString *)text size:(CGFloat)size frontColor:(CIColor *)fColor backColor:(CIColor *)bColor watermark:(UIImage *)watermark;

@end
