//
//  UIImage+QRCode.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/25.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "UIImage+QRCode.h"

@implementation UIImage (QRCode)

+ (UIImage *)imageWithQRText:(NSString *)text {
    return [UIImage imageWithQRText:text size:256];
}

+ (UIImage *)imageWithQRText:(NSString *)text size:(CGFloat)size {
    CGFloat imageWidth = MAX(27, size);
    CIImage *ciImage = [UIImage QRCodeOriginalCIImage:text];
    
    CGRect extent = CGRectIntegral(ciImage.extent);
    CGFloat scale = MIN(imageWidth / CGRectGetWidth(extent), imageWidth / CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGContextRef context = CGBitmapContextCreate(nil, width, height, 8, 0, CGColorSpaceCreateDeviceGray(), (CGBitmapInfo)kCGImageAlphaNone);
    CGImageRef imageRef = [[CIContext contextWithOptions:nil] createCGImage:ciImage fromRect:extent];
    
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextScaleCTM(context, scale, scale);
    CGContextDrawImage(context, extent, imageRef);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(context);
    UIImage *codeImage = [UIImage imageWithCGImage:scaledImage];
    
    CGContextRelease(context);
    CGImageRelease(imageRef);
    CGImageRelease(scaledImage);
    
    return codeImage;
}

+ (UIImage *)imageWithQRText:(NSString *)text size:(CGFloat)size watermark:(UIImage *)watermark {
    UIImage *normalImage = [UIImage imageWithQRText:text size:size];
    if (!watermark) {
//        NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
//        NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
//        watermark = [UIImage imageNamed:icon];
        return normalImage;
    }
    
    CGFloat imageWidth = normalImage.size.width;
    //加水印
    UIGraphicsBeginImageContextWithOptions(normalImage.size, NO, 0);
    [normalImage drawInRect:CGRectMake(0, 0, imageWidth, imageWidth)];
    CGFloat waterImagesize = imageWidth * 0.5;
    [watermark drawInRect:CGRectMake((imageWidth - waterImagesize)/2.0, (imageWidth - waterImagesize)/2.0, waterImagesize, waterImagesize)];
    UIImage *watermarkImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return watermarkImage;
}

+ (UIImage *)imageWithQRText:(NSString *)text size:(CGFloat)size frontColor:(CIColor *)fColor backColor:(CIColor *)bColor {
    UIImage *normalImage = [UIImage imageWithQRText:text size:size];
    if ((!fColor && !bColor)) {
        return normalImage;
    }
    
    CGFloat fRed = 0;
    CGFloat fGreen = 0;
    CGFloat fBlue = 0;
    if (fColor) {
        const CGFloat *fComponents = fColor.components;
        fRed = fComponents[0] * 255;
        fGreen = fComponents[1] * 255;
        fBlue = fComponents[2] * 255;
    }
    
    CGFloat bRed = 255;
    CGFloat bGreen = 255;
    CGFloat bBlue = 255;
    if (bColor) {
        const CGFloat *bComponents = bColor.components;
        bRed = bComponents[0] * 255;
        bGreen = bComponents[1] * 255;
        bBlue = bComponents[2] * 255;
    }
    
    const int colorWidth = normalImage.size.width;
    const int colorHeight = normalImage.size.height;
    
    size_t bytesPerRow = colorWidth * 4;
    uint32_t *rgbImageBuf = (uint32_t*)malloc(bytesPerRow * colorHeight);
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, colorWidth, colorHeight, 8, bytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, colorWidth, colorHeight), normalImage.CGImage);
    // 遍历像素
    int pixelNum = colorWidth * colorHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900) {
            // 改成下面的代码，会将图片转成想要的颜色。这里理解为：二维码颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = fRed; //0~255
            ptr[2] = fGreen;
            ptr[1] = fBlue;
        } else {
            //这里理解为：背景色
            uint8_t* ptr = (uint8_t*)pCurPtr;
//            ptr[0] = 0;//透明
            ptr[3] = bRed; //0~255
            ptr[2] = bGreen;
            ptr[1] = bBlue;
        }
    }
    // 输出图片
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *colorImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGContextRelease(context);
    
    return colorImage;
}

+ (UIImage *)imageWithQRText:(NSString *)text size:(CGFloat)size frontColor:(CIColor *)fColor backColor:(CIColor *)bColor watermark:(UIImage *)watermark {
    UIImage *colorImage = [UIImage imageWithQRText:text size:size frontColor:fColor backColor:bColor];
    
    if (!watermark) {
        return colorImage;
    } else {
        CGFloat imageWidth = colorImage.size.width;
        //加水印
        UIGraphicsBeginImageContextWithOptions(colorImage.size, NO, 0);
        [colorImage drawInRect:CGRectMake(0, 0, imageWidth, imageWidth)];
        CGFloat waterImagesize = imageWidth * 0.5;
        [watermark drawInRect:CGRectMake((imageWidth - waterImagesize)/2.0, (imageWidth - waterImagesize)/2.0, waterImagesize, waterImagesize)];
        UIImage *watermarkImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return watermarkImage;
    }
}

#pragma mark
+ (CIImage *)QRCodeOriginalCIImage:(NSString *)text {
    NSData *stringData = [text dataUsingEncoding:NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    return qrFilter.outputImage;
}

@end