//
//  QRCodeGenerator.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/25.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "QRCodeGenerator.h"

#import "QRCodePixel.h"

@implementation QRCodeGenerator

- (instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _codeWidth = 256;
    _foregroundColor = [UIColor blackColor];
    _backgroundColor = [UIColor whiteColor];
    
    _isIconColorful = YES;
    _isWatermarkColorful = YES;
    _allowTransparent = NO;
}

- (UIImage *)QRCodeImage {
    if (!self.content || self.content.length == 0) {
        return nil;
    }
    
    NSArray *pixels = [self getPixels:self.content];
    NSArray *codes = [self getCodes:pixels];
    
    CGSize size = CGSizeMake(_codeWidth, _codeWidth);
    CGContextRef context = [self createContext:size];
    
    if (self.allowTransparent) {//透明，不知道啥意思******
        CGImageRef frontImage = [self createFrontImage:codes size:size codeColor:_foregroundColor];
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), frontImage);
        CGImageRelease(frontImage);
    }
    
    if (self.watermark) {
        //水印
        [self drawWatermark:context image:_watermark.CGImage size:size backgroundColor:_backgroundColor];
        
        //透明二维码
        CGImageRef frontImage = [self createFrontImageTransparent:codes
                                                             size:size
                                                       frontColor:_foregroundColor
                                                        backColor:_backgroundColor];
        UIImage *image = [self drawFrontImage:context image:frontImage size:size];
        
        return image;
        
    } else {
        //背景色
        CGContextSetFillColorWithColor(context, _backgroundColor.CGColor);
        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
        
        //二维码
        CGImageRef frontImage = [self createFrontImage:codes size:size codeColor:_foregroundColor];
        UIImage *image = [self drawFrontImage:context image:frontImage size:size];
        
        return image;
    }
}

- (UIImage *)drawFrontImage:(CGContextRef)context image:(CGImageRef)frontImage size:(CGSize)size {
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), frontImage);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(frontImage);
    CGImageRelease(imageRef);
    
    return image;
}

#pragma mark
- (NSMutableArray *)getPixels:(NSString *)qrString {
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *ciImage = qrFilter.outputImage;
    CGImageRef cgimage = [[CIContext contextWithOptions:nil] createCGImage:ciImage fromRect:ciImage.extent];
    CGDataProviderRef provider = CGImageGetDataProvider(cgimage);
    CFDataRef dataRef = CGDataProviderCopyData(provider);
    UInt8 *data = (UInt8 *)CFDataGetBytePtr(dataRef);
    
    NSMutableArray *codePixels = [NSMutableArray array];
    for (int indexY = 0; indexY < CGImageGetHeight(cgimage); indexY++) {
        NSMutableArray *arrayM = [NSMutableArray array];
        
        for (int indexX = 0; indexX < CGImageGetWidth(cgimage); indexX++) {
            NSInteger pixelInfo = ((CGImageGetWidth(cgimage) * indexY) + indexX) * 4;
            QRCodePixel *pixel = [[QRCodePixel alloc] init];
            pixel.red = data[pixelInfo];
            pixel.green = data[pixelInfo + 1];
            pixel.blue = data[pixelInfo + 2];
            pixel.alpha = data[pixelInfo + 3];
            
            [arrayM addObject:pixel];
        }
        
        [codePixels addObject:arrayM];
    }
    
    CGImageRelease(cgimage);
    CGDataProviderRelease(provider);
    
    return codePixels;
}

- (NSMutableArray *)getCodes:(NSArray *)codePixels {
    NSMutableArray *codes = [NSMutableArray array];
    
    for (NSArray *array in codePixels) {
        NSMutableArray *arrayM = [NSMutableArray array];
        
        for (QRCodePixel *pixel in array) {
            BOOL flag = NO;
            if (pixel.red == 0 && pixel.green == 0 && pixel.blue == 0) {
                flag = YES;
            }
            
            [arrayM addObject:@(flag)];
        }
        [codes addObject:arrayM];
    }
    
    return codes;
}

- (CGContextRef)createContext:(CGSize)size {
    return CGBitmapContextCreate(nil, size.width, size.height, 8, 0, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
}

#pragma mark
- (CGImageRef)createFrontImage:(NSArray *)codes size:(CGSize)size codeColor:(UIColor *)codeColor {
    CGContextRef context = [self createContext:size];
    CGFloat scaleX = size.width / codes.count;
    CGFloat scaleY = size.height / codes.count;
    
    NSInteger codeSize = codes.count;
    CGContextSetFillColorWithColor(context, codeColor.CGColor);
    
    for (int indexY = 0; indexY < codeSize; indexY++) {
        NSArray *array = codes[indexY];
        
        for (int indexX = 0; indexX < codeSize; indexX++) {
            BOOL flag = [array[indexX] boolValue];
            if (flag) {
                NSInteger indexXCTM = indexY;
                NSInteger indexYCTM = codeSize - indexX - 1;
                CGContextFillRect(context, CGRectMake(indexXCTM * scaleX, indexYCTM * scaleY, scaleX, scaleY));
            }
        }
    }
    
    return CGBitmapContextCreateImage(context);
}

- (CGImageRef)createFrontImageTransparent:(NSArray *)codes size:(CGSize)size frontColor:(UIColor *)frontColor backColor:(UIColor *)backColor {
    CGFloat scaleX = size.width / codes.count;
    CGFloat scaleY = size.height / codes.count;
    
    NSInteger codeSize = codes.count;
    CGFloat pointMinOffsetX = scaleX / 3;
    CGFloat pointMinOffsetY = scaleY / 3;
    CGFloat pointWidthOriX = scaleX;
    CGFloat pointWidthOriY = scaleY;
    CGFloat pointWidthMinX = scaleX - 2 * pointMinOffsetX;
    CGFloat pointWidthMinY = scaleY - 2 * pointMinOffsetY;
    
    NSMutableArray *points = [NSMutableArray array];
    NSArray *locations = [self getAlignmentPatternLocations:codeSize];
    for (int indexX = 0; indexX < locations.count; indexX++) {
        for (int indexY = 0; indexY < locations.count; indexY++) {
            
            NSInteger finalX = [locations[indexX] integerValue] + 1;
            NSInteger finalY = [locations[indexY] integerValue] + 1;
            
            if (!(finalX == 7 && finalY == 7) || !(finalX == 7 && finalY == (codeSize - 8)) || !(finalX == (codeSize - 8) && finalY == 7)) {
                NSValue *value = [NSValue valueWithCGPoint:CGPointMake(finalX, finalY)];
                [points addObject:value];
            }
        }
    }
    
    //********************************
    CGContextRef context = [self createContext:size];
    CGContextSetFillColorWithColor(context, backColor.CGColor);
    
    for (int indexY = 0; indexY < codeSize; indexY++) {
        NSArray *array = codes[indexY];
        
        for (int indexX = 0; indexX < codeSize; indexX++) {
            BOOL flag = [array[indexX] boolValue];
            if (!flag) {
                // CTM-90
                NSInteger indexXCTM = indexY;
                NSInteger indexYCTM = codeSize - indexX - 1;
                
                if ([self isStaticX:indexX y:indexY size:codeSize point:points]) {
                    CGContextFillRect(context, CGRectMake(indexXCTM * scaleX, indexYCTM * scaleY, pointWidthOriX, pointWidthOriY));
                } else {
                    CGContextFillRect(context, CGRectMake(indexXCTM * scaleX + pointMinOffsetX, indexYCTM * scaleY + pointMinOffsetY, pointWidthMinX, pointWidthMinY));
                }
            }
        }
    }
    
    //********************************
    CGContextSetFillColorWithColor(context, frontColor.CGColor);
    
    for (int indexY = 0; indexY < codeSize; indexY++) {
        NSArray *array = codes[indexY];
        
        for (int indexX = 0; indexX < codeSize; indexX++) {
            BOOL flag = [array[indexX] boolValue];
            if (flag) {
                // CTM-90
                NSInteger indexXCTM = indexY;
                NSInteger indexYCTM = codeSize - indexX - 1;
                
                if ([self isStaticX:indexX y:indexY size:codeSize point:points]) {
                    CGContextFillRect(context, CGRectMake(indexXCTM * scaleX, indexYCTM * scaleY, pointWidthOriX, pointWidthOriY));
                } else {
                    CGContextFillRect(context, CGRectMake(indexXCTM * scaleX + pointMinOffsetX, indexYCTM * scaleY + pointMinOffsetY, pointWidthMinX, pointWidthMinY));
                }
            }
        }
    }
    
    return CGBitmapContextCreateImage(context);
}

- (void)drawWatermark:(CGContextRef)context image:(CGImageRef)image size:(CGSize)size backgroundColor:(UIColor *)backColor {
    CGContextSetFillColorWithColor(context, backColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    CGSize finalSize = size;
    CGPoint finalOrigin = CGPointZero;
    if (_watermarkMode == WatermarkModeScaleAspectFit) {
        CGFloat scale = MAX(CGImageGetWidth(_watermark.CGImage) / size.width, CGImageGetHeight(_watermark.CGImage) / size.height);
        finalSize = CGSizeMake(CGImageGetWidth(_watermark.CGImage) / scale, CGImageGetHeight(_watermark.CGImage) / scale);
        finalOrigin = CGPointMake((size.width - finalSize.width) / 2.0, (size.height - finalSize.height) / 2.0);
    } else if (_watermarkMode == WatermarkModeScaleAspectFill) {
        CGFloat scale = MIN(CGImageGetWidth(_watermark.CGImage) / size.width, CGImageGetHeight(_watermark.CGImage) / size.height);
        finalSize = CGSizeMake(CGImageGetWidth(_watermark.CGImage) / scale, CGImageGetHeight(_watermark.CGImage) / scale);
        finalOrigin = CGPointMake((size.width - finalSize.width) / 2.0, (size.height - finalSize.height) / 2.0);
    }
    CGRect finalrect = {finalOrigin,finalSize};
    
    if (_isWatermarkColorful) {
        CGContextDrawImage(context, finalrect, _watermark.CGImage);
    } else {
        CGContextDrawImage(context, finalrect, [self grayImage:_watermark.CGImage]);
    }
}

#pragma mark
- (NSMutableArray *)getAlignmentPatternLocations:(NSInteger)codeSize {
    NSInteger version =  (codeSize - 21) / 4 + 1;
    if (version == 1) {
        return nil;
    }
    
    NSInteger divs = 2 + version / 7;
    NSInteger size = 17 + 4 * version;
    NSInteger total_dist = size - 7 - 6;
    NSInteger divisor = 2 * (divs - 1);
    
    // Step must be even, for alignment patterns to agree with timing patterns
    NSInteger step = (total_dist + divisor / 2 + 1) / divisor * 2; // Get the rounding right
    NSMutableArray *coords = [NSMutableArray arrayWithCapacity:6];
    
    // divs-2 down to 0, inclusive
    for (int i = 0; i < divs - 2; i++) {
        [coords addObject:@(size - 7 - (divs - 2 - i) * step)];
    }
    
    return coords;
}

- (BOOL)isStaticX:(NSInteger)x y:(NSInteger)y size:(NSInteger)size point:(NSArray *)points {
    if (x == 0 || y == 0 || x == (size - 1) || y == (size - 1)) {
        return YES;
    }
    
    // Finder Patterns
    if ((x <= 8 && y <= 8) || (x <= 8 && y >= (size - 9)) || (x >= (size - 9) && y <= 8)) {
        return YES;
    }
    
    // Timing Patterns
    if (x == 7 || y == 7) {
        return YES;
    }
    
    // Alignment Patterns
    for (NSValue *value in points) {
        CGPoint point = [value CGPointValue];
        if (x >= (point.x - 2) && x <= (point.x + 2) && y >= (point.y - 2) && y <= (point.y + 2)) {
            return YES;
        }
    }
    
    return NO;
}

- (CGImageRef)grayImage:(CGImageRef)imageRef {
    CGContextRef context = CGBitmapContextCreate(nil, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), 8, 4 * CGImageGetWidth(imageRef), CGColorSpaceCreateDeviceGray(), (CGBitmapInfo)kCGImageAlphaNone);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)), imageRef);
    return CGBitmapContextCreateImage(context);
}

@end
