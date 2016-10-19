//
//  PhotosCollectionViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/11.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "PhotosViewController.h"

#import "DDImageBrowserController.h"
#import "DDVideoPlayController.h"

@interface PhotosViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,DDImageBrowserDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *thumbImages;

@end

@implementation PhotosViewController

static NSString * const reuseIdentifier = @"Cell";

- (NSArray *)thumbImages {
    if (!_thumbImages) {
        _thumbImages = [NSMutableArray arrayWithCapacity:self.fetchResult.count];
    }
    
    return _thumbImages;
}

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
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake((ScreenWidth - 50) / 4, (ScreenWidth - 50) / 4);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 10, 10);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)
                                         collectionViewLayout:flowLayout];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
    
    [self.view addSubview:_collectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [cell.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    PHAsset *asset = self.fetchResult[indexPath.row];
    CGSize itemSize = CGSizeMake((ScreenWidth - 50) / 4, (ScreenWidth - 50) / 4);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, itemSize.width, itemSize.height)];
    [cell.contentView addSubview:imageView];
    
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, itemSize.height - 15, itemSize.width, 15)];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:10];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
        label.text = @"video";
        [cell.contentView addSubview:label];
    }
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    options.synchronous = YES;
    
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:CGSizeZero
                                              contentMode:PHImageContentModeAspectFit
                                                  options:options
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                
                                                imageView.image = [self resizeImage:result];
                                                self.thumbImages[indexPath.row] = result;
                                            }];
    
    
    return cell;
}

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


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DDImageBrowserController *controller = [[DDImageBrowserController alloc] init];
    controller.browserDelegate = self;
    controller.thumbImages = self.thumbImages;
    controller.currentIndex = indexPath.row;
    
    [self.navigationController pushViewController:controller animated:YES];
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
    
    //targetSize为PHImageManagerMaximumSize时，加载图片本身尺寸、质量，这里用默认options，是异步加载
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:PHImageManagerMaximumSize
                                              contentMode:PHImageContentModeAspectFit
                                                  options:nil
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                [controller showHighQualityImageOfIndex:index withImage:result];
                                                
                                            }];
}

- (void)controller:(DDImageBrowserController *)controller didSelectAtIndex:(NSInteger)index {
    PHAsset *asset = self.fetchResult[index];
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        NSLog(@"play");
        
        
    }
}

@end




