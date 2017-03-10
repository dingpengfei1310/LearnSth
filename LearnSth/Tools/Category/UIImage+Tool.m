//
//  UIImage+Tool.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UIImage+Tool.h"
#import <Photos/Photos.h>
#import <Accelerate/Accelerate.h>

@implementation UIImage (Tool)

#pragma mark
+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1.0, 1.0);
    UIGraphicsBeginImageContext(rect.size);
    
    [color setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark
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
//    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UIColor whiteColor].CGColor);
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

#pragma mark
- (void)saveImageIntoAlbum {
    [self saveImageIntoAlbumWithTitle:nil];
}

- (void)saveImageIntoAlbumWithTitle:(NSString *)title {
    // 获得相片
    PHFetchResult<PHAsset *> *createdAssets = [self createAssets];
    // 获得相册
    PHAssetCollection *createdCollection = [self createAssetCollectionWithTitle:title];
    
    if (createdAssets == nil || createdCollection == nil) {
        NSLog(@"%@",@"保存失败");
        return;
    }
    // 将相片添加到相册
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
        [request insertAssets:createdAssets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    // 保存结果
    if (error) {
        NSLog(@"%@",@"保存失败");
    } else {
        NSLog(@"%@",@"保存成功");
    }
}

- (PHFetchResult<PHAsset *> *)createAssets {
    UIImage *image = [UIImage imageNamed:@"lookup"];
    
    __block NSString *createdAssetId = nil;
    // 添加图片到【相机胶卷】
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:nil];
    // 在保存完毕后取出图片
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];
}

- (PHAssetCollection *)createAssetCollectionWithTitle:(NSString *)title {
    if (!title) {
        // 获取软件的名字作为相册的标题(如果需求不是要软件名称作为相册名字就可以自己把这里改成想要的名称)
        title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        //NSString *title = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
    }
    
    // 获得所有的自定义相册
    PHFetchResult *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:title]) {
            return collection;
        }
    }
    // 代码执行到这里，说明还没有自定义相册
    __block NSString *createdCollectionId = nil;
    // 创建一个新的相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdCollectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
    } error:nil];
    
    // 创建完毕后再取出相册
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCollectionId] options:nil].firstObject;
}

#pragma mark
- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage {
    NSAssert(self.size.width > 0 && self.size.height > 0, @"Size must be positive: Both dimensions msut be >= 1.");
    NSAssert(self.CGImage != nil, @"image must be backed by a CGImage.");
    NSAssert(!maskImage || maskImage.CGImage, @"maskImage, if given, must be backed by a CGImage.");
    
    UIImage *image = self;
    const CGRect rect = {CGPointZero, image.size};
    const CGFloat scale = UIScreen.mainScreen.scale;
    
    const BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    const BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale);
        CGContextRef inputContext = UIGraphicsGetCurrentContext();
        [image drawAtPoint:CGPointZero];
        
        vImage_Buffer inputBuffer = vImageBuffer_InitWithCGContext(inputContext);
        
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale);
        vImage_Buffer outputBuffer = vImageBuffer_InitWithCGContext(UIGraphicsGetCurrentContext());
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * 1;
//            NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            uint32_t radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            
            vImageBoxConvolve_ARGB8888(&inputBuffer,  &outputBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&outputBuffer, &inputBuffer,  NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&inputBuffer,  &outputBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            
            // Swap input & output
            vImage_Buffer tempBuffer = inputBuffer;
            inputBuffer = outputBuffer;
            outputBuffer = tempBuffer;
        }
        
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            
            const int32_t divisor = 256;
            
            // Convert saturation matrix from float to int
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            
            vImageMatrixMultiply_ARGB8888(&inputBuffer, &outputBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
        }
        
        if (!hasBlur) {
            image = UIGraphicsGetImageFromCurrentImageContext();
        }
        UIGraphicsEndImageContext();
        
        if (hasBlur) {
            image = UIGraphicsGetImageFromCurrentImageContext();
        }
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    
    // Draw base image.
    [self drawAtPoint:rect.origin];
    
    // Draw effect image.
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, rect, maskImage.CGImage);
        }
        [image drawAtPoint:rect.origin];
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, rect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

vImage_Buffer vImageBuffer_InitWithCGContext(CGContextRef contextRef) {
    return (vImage_Buffer){
        .width = CGBitmapContextGetWidth(contextRef),
        .height = CGBitmapContextGetHeight(contextRef),
        .rowBytes = CGBitmapContextGetBytesPerRow(contextRef),
        .data = CGBitmapContextGetData(contextRef),
    };
}

@end
