//
//  UIImage+Tool.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UIImage+Tool.h"

@implementation UIImage (Tool)

- (UIImage *)resizeImageWithSize:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(size);
    [self drawInRect:rect];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (UIImage *)cornerImageWithSize:(CGSize)size radius:(CGFloat)radius; {
    radius = (radius < size.width / 2) ? radius : size.width / 2;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
    [[self getCenterImage] drawInRect:rect];
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UIColor whiteColor].CGColor);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (UIImage *)getCenterImage {
    CGSize imageSize = self.size;
    CGFloat originX = 0;
    CGFloat originY = 0;
    
    if (imageSize.width > imageSize.height) {
        originX = (imageSize.width - imageSize.height) * 0.5;
        originY = 0.0;
        imageSize = CGSizeMake(imageSize.height, imageSize.height);
    } else {
        originX = 0.0;
        originY = (imageSize.height - imageSize.width) * 0.5;
        imageSize = CGSizeMake(imageSize.width, imageSize.width);
    }
    
    CGRect rect = CGRectMake(originX, originY, imageSize.width, imageSize.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *result = [[UIImage alloc] initWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    return result;
}

@end


