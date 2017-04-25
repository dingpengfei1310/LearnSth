//
//  UIImage+QRCode.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/25.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QRCode)

+ (UIImage *)imageWithQRText:(NSString *)text;
+ (UIImage *)imageWithQRText:(NSString *)text size:(CGFloat)size;

+ (UIImage *)imageWithQRText:(NSString *)text size:(CGFloat)size watermark:(UIImage *)watermark;
+ (UIImage *)imageWithQRText:(NSString *)text size:(CGFloat)size frontColor:(CIColor *)fColor backColor:(CIColor *)bColor;
+ (UIImage *)imageWithQRText:(NSString *)text size:(CGFloat)size frontColor:(CIColor *)fColor backColor:(CIColor *)bColor watermark:(UIImage *)watermark;

@end
