//
//  QRCodeGenerator.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/25.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "QRCodeGenerator.h"

@interface QRCodePixel : NSObject

@property (nonatomic, assign) uint8_t red;
@property (nonatomic, assign) uint8_t green;
@property (nonatomic, assign) uint8_t blue;
@property (nonatomic, assign) uint8_t alpha;

@end

@implementation QRCodePixel
@end

@implementation QRCodeGenerator

- (instancetype)init {
    if (self = [super init]) {
        _codeWidth = 256;
        _foregroundColor = [UIColor blackColor];
        _backgroundColor = [UIColor whiteColor];
        
        _isIconColorful = YES;
        _isWatermarkColorful = YES;
        _allowTransparent = NO;
    }
    return self;
}

- (UIImage *)QRCodeImage {
    if (!self.content || self.content.length == 0) {
        return nil;
    }
    
    NSArray *codes = [self getCodes];
    _codeWidth = MAX(codes.count, _codeWidth);
    CGSize size = CGSizeMake(_codeWidth, _codeWidth);
    CGContextRef context = [self createContext:size];
    
    if (self.watermark) {
        //水印(包括背景色)
        [self drawWatermark:context codes:codes size:size ];
        
        //（透明）二维码
        CGImageRef frontImage = [self createFrontImageTransparent:codes size:size];
        
        //画二维码
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), frontImage);
        CGImageRelease(frontImage);
    } else {
        //背景色
        CGContextSetFillColorWithColor(context, _backgroundColor.CGColor);
        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
        
        //二维码
        CGImageRef frontImage = [self createFrontImage:codes size:size];
        
        //画二维码
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), frontImage);
        CGImageRelease(frontImage);
    }
    
    if (self.icon) {
        //默认居中
        CGFloat iconW = size.width * 0.3;
        CGFloat iconX = (size.width - iconW) * 0.5;
        CGRect iconRect = CGRectMake(iconX, iconX, iconW, iconW);
        
        if (self.isIconColorful) {
            CGContextDrawImage(context, iconRect, self.icon.CGImage);
        } else {
            CGContextDrawImage(context, iconRect, [self grayImage:self.icon.CGImage]);
        }
    }
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGContextRelease(context);
    
    return image;
}

#pragma mark
- (CGImageRef)createFrontImage:(NSArray *)codes size:(CGSize)size {
    NSInteger codeSize = codes.count;
    CGFloat scaleX = size.width / codeSize;
    CGFloat scaleY = size.height / codeSize;
    
    CGContextRef context = [self createContext:size];
    CGContextSetFillColorWithColor(context, _foregroundColor.CGColor);
    
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

- (CGImageRef)createFrontImageTransparent:(NSArray *)codes size:(CGSize)size {
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
    
    
    CGContextRef context = [self createContext:size];
    //_backgroundColor
    CGContextSetFillColorWithColor(context, _backgroundColor.CGColor);
    
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
    
    //_foregroundColor
    CGContextSetFillColorWithColor(context, _foregroundColor.CGColor);
    
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

- (void)drawWatermark:(CGContextRef)context codes:(NSArray *)codes size:(CGSize)size {
    //背景色
    CGContextSetFillColorWithColor(context, _backgroundColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    if (self.allowTransparent) {//透明(先画了一次二维码)
        CGImageRef frontImage = [self createFrontImage:codes size:size];
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), frontImage);
        CGImageRelease(frontImage);
    }
    
    //水印frame
    CGSize finalSize = size;
    CGPoint finalOrigin = CGPointZero;
    CGFloat imageW = CGImageGetWidth(_watermark.CGImage);
    CGFloat imageH = CGImageGetHeight(_watermark.CGImage);
    
    if (_watermarkMode == WatermarkModeScaleAspectFit) {
        CGFloat scale = MAX(imageW / size.width, imageH / size.height);
        finalSize = CGSizeMake(imageW / scale, imageH / scale);
        finalOrigin = CGPointMake((size.width - finalSize.width) / 2.0, (size.height - finalSize.height) / 2.0);
        
    } else if (_watermarkMode == WatermarkModeScaleAspectFill) {
        CGFloat scale = MIN(imageW / size.width, imageH / size.height);
        finalSize = CGSizeMake(imageW / scale, imageH / scale);
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
- (NSMutableArray *)getCodes {
    NSData *data = [_content dataUsingEncoding:NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:data forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *outputImage = qrFilter.outputImage;
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:outputImage fromRect:outputImage.extent];
    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
    CFDataRef dataRef = CGDataProviderCopyData(provider);
    UInt8 *dataByte = (UInt8 *)CFDataGetBytePtr(dataRef);
    
    //codePixels
    NSMutableArray *codePixels = [NSMutableArray array];
    for (int indexY = 0; indexY < CGImageGetHeight(cgImage); indexY++) {
        NSMutableArray *arrayM = [NSMutableArray array];
        
        for (int indexX = 0; indexX < CGImageGetWidth(cgImage); indexX++) {
            NSInteger pixelInfo = ((CGImageGetWidth(cgImage) * indexY) + indexX) * 4;
            QRCodePixel *pixel = [[QRCodePixel alloc] init];
            pixel.red = dataByte[pixelInfo];
            pixel.green = dataByte[pixelInfo + 1];
            pixel.blue = dataByte[pixelInfo + 2];
            pixel.alpha = dataByte[pixelInfo + 3];
            
            [arrayM addObject:pixel];
        }
        
        [codePixels addObject:arrayM];
    }
    
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    
    //codes
    NSMutableArray *codes = [NSMutableArray array];
    for (NSArray *array in codePixels) {
        NSMutableArray *arrayM = [NSMutableArray array];
        
        for (QRCodePixel *pixel in array) {
            BOOL flag = (pixel.red == 0 && pixel.green == 0 && pixel.blue == 0);
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
//不知道这个方法的原理是啥
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

//不知道这个方法的原理是啥
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
