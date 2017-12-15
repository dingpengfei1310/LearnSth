//
//  QRCodeRecognizer.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/26.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "QRCodeRecognizer.h"

@implementation QRCodeRecognizer

- (NSString *)getQRString {
    if (!_codeImage) {
        return nil;
    }
    
    //初始化扫描仪，设置设别类型和识别质量
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:_codeImage.CGImage]];
    
    if (features.count == 0) {
        features = [detector featuresInImage:[CIImage imageWithCGImage:[self grayImage:_codeImage.CGImage]]];
    }
    
    NSString *message;
    if (features.count > 0) {
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        message = feature.messageString;
    }
    
    return message;
}

- (CGImageRef)grayImage:(CGImageRef)imageRef {
    CGContextRef context = CGBitmapContextCreate(nil, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), 8, 4 * CGImageGetWidth(imageRef), CGColorSpaceCreateDeviceGray(), (CGBitmapInfo)kCGImageAlphaNone);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)), imageRef);
    return CGBitmapContextCreateImage(context);
}

@end
