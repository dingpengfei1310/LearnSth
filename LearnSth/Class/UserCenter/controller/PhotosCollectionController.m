//
//  PhotosCollectionViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/11.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "PhotosCollectionController.h"

#import "PhotosCollectionCell.h"
#import "DDImageBrowserController.h"

@interface PhotosCollectionController ()<UICollectionViewDataSource,UICollectionViewDelegate,DDImageBrowserDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *thumbImages;//图片（不包括视频）

@end

static NSString * const reuseIdentifier = @"Cell";
const CGFloat interitemSpacing = 5.0;
const NSInteger photoColumn = 4;

@implementation PhotosCollectionController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.fetchResult) {
        if ([self.assetCollection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)self.assetCollection;
            // 从每一个智能相册中获取到的 PHFetchResult 中包含的才是真正的资源（PHAsset）
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
            self.fetchResult = fetchResult;
            
        } else {
            NSAssert(NO, @"Fetch collection not PHCollection: %@", self.assetCollection);
            return;
        }
    }
    
    [self.view addSubview:self.collectionView];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotosCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    PHAsset *asset = self.fetchResult[indexPath.row];
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        cell.videoLabel.text = @"Video";
    }
    
    UIImage *result = self.thumbImages[indexPath.row];
    cell.photoImageView.image = [self resizeImage:result];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDImageBrowserController *controller = [[DDImageBrowserController alloc] init];
    controller.browserDelegate = self;
    controller.thumbImages = self.thumbImages;
    controller.currentIndex = indexPath.row;
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark
- (UIImage *)resizeImage:(UIImage *)originalImage {
    if (!originalImage) return nil;
    
    CGFloat imageWidth = CGImageGetWidth([originalImage CGImage]);
    CGFloat imageHeight = CGImageGetHeight([originalImage CGImage]);
    CGRect rect;
    
    if (imageWidth > imageHeight) {
        rect = CGRectMake((imageWidth - imageHeight) / 2.0, 0, imageHeight, imageHeight);
    } else {
        rect = CGRectMake(0, (imageHeight - imageWidth) / 2.0, imageWidth, imageWidth);
    }
    
    CGImageRef cgImage = CGImageCreateWithImageInRect(originalImage.CGImage, rect);
    UIImage *resultImage = [UIImage imageWithCGImage:cgImage];;
    CGImageRelease(cgImage);
    
    return resultImage;
}

#pragma mark - DDImageBrowserDelegate
- (UIImage *)controller:(DDImageBrowserController *)controller placeholderImageOfIndex:(NSInteger)index {
    return self.thumbImages[index];
}

//- (NSURL *)controller:(DDImageBrowserController *)controller imageUrlOfIndex:(NSInteger)index {
//    return nil;
//}

- (void)controller:(DDImageBrowserController *)controller didScrollToIndex:(NSInteger)index {
    PHAsset *asset = self.fetchResult[index];
    [controller showHighQualityImageOfIndex:index WithAsset:asset];
//    BOOL flag = (asset.mediaType == PHAssetMediaTypeVideo) ? YES : NO;//是否是视频
////    //targetSize为PHImageManagerMaximumSize时，加载图片本身尺寸、质量，这里用默认options，是异步加载
////    //用这个方法内存会很高，而且不释放。下面：requestImageDataForAsset，方法更好
////    [[PHImageManager defaultManager] requestImageForAsset:asset
////                                               targetSize:PHImageManagerMaximumSize
////                                              contentMode:PHImageContentModeAspectFit
////                                                  options:nil
////                                            resultHandler:^(UIImage *result, NSDictionary *info) {
////                                                [controller showHighQualityImageOfIndex:index withImage:result];
////                                            }];
//    
//    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//        
//        UIImage *result = [UIImage imageWithData:imageData];
//        [controller showHighQualityImageOfIndex:index withImage:result videoFlag:flag];
//    }];
}

//- (void)controller:(DDImageBrowserController *)controller didSelectAtIndex:(NSInteger)index {
//    PHAsset *asset = self.fetchResult[index];
//    
//    if (asset.mediaType == PHAssetMediaTypeVideo) {
//        PhotoVideoViewController *videoController = [[PhotoVideoViewController alloc] init];
//        videoController.asset = asset;
//        [self.navigationController pushViewController:videoController animated:YES];
//    }
//}

#pragma mark
- (NSMutableArray *)thumbImages {
    if (!_thumbImages) {
        _thumbImages = [NSMutableArray arrayWithCapacity:self.fetchResult.count];
        
        for (int i = 0; i < self.fetchResult.count; i++) {
            PHAsset *asset = self.fetchResult[i];
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
            options.synchronous = YES;
            //这里不用requestImageDataForAsset
            [[PHImageManager defaultManager] requestImageForAsset:asset
                                                       targetSize:CGSizeZero
                                                      contentMode:PHImageContentModeAspectFit
                                                          options:options
                                                    resultHandler:^(UIImage * result, NSDictionary * info) {
                                                        self.thumbImages[i] = result;
                                                    }];
        }
    }
    return _thumbImages;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat itemWidth = (Screen_W - (photoColumn + 1) * interitemSpacing) / photoColumn;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
        flowLayout.sectionInset = UIEdgeInsetsMake(5, interitemSpacing, 5, interitemSpacing);
        flowLayout.minimumInteritemSpacing = interitemSpacing;
        flowLayout.minimumLineSpacing = interitemSpacing;
        
        CGRect collectionViewRect = CGRectMake(0, ViewFrame_X, Screen_W, Screen_H - 64);
        _collectionView = [[UICollectionView alloc] initWithFrame:collectionViewRect
                                             collectionViewLayout:flowLayout];
        UINib *nib = [UINib nibWithNibName:@"PhotosCollectionCell" bundle:[NSBundle mainBundle]];
        [_collectionView registerNib:nib forCellWithReuseIdentifier:reuseIdentifier];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
