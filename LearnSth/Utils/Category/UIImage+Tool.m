//
//  UIImage+Tool.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UIImage+Tool.h"
#import <Photos/Photos.h>

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

@end

