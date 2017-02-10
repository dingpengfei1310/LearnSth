//
//  PhotosCollectionViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/11.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "PhotosCollectionController.h"
#import "DDImageBrowserController.h"
#import "DDImageBrowserVideo.h"

#import "PhotosCollectionCell.h"

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
    [self.view addSubview:self.collectionView];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotosCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.videoLabel.text = nil;
    PHAsset *asset = self.fetchResult[indexPath.row];
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        cell.videoLabel.text = @"Video";
    }
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    options.synchronous = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeZero contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        cell.photoImageView.image = [self resizeImage:result];
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = self.fetchResult[indexPath.row];
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        DDImageBrowserVideo *controller = [[DDImageBrowserVideo alloc] init];
        controller.asset = asset;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        DDImageBrowserController *controller = [[DDImageBrowserController alloc] init];
        controller.browserDelegate = self;
        controller.thumbImages = self.thumbImages;
        
        int count = 0;
        for (int i = 0; i < indexPath.row; i++) {
            PHAsset *tempAsset = self.fetchResult[i];
            if (tempAsset.mediaType != PHAssetMediaTypeVideo) {
                count++;
            }
        }
        
        controller.currentIndex = count;
        [self.navigationController pushViewController:controller animated:YES];
    }
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
- (void)controller:(DDImageBrowserController *)controller didScrollToIndex:(NSInteger)index {
    
    int count = 0;
    for (int i = 0; i < self.fetchResult.count; i++) {
        PHAsset *tempAsset = self.fetchResult[i];
        if (tempAsset.mediaType != PHAssetMediaTypeVideo) {
            if (count == index) {
                [controller showHighQualityImageOfIndex:index WithAsset:tempAsset];
                return;
            }
            count++;
        }
    }
}

#pragma mark
- (NSMutableArray *)thumbImages {
    if (!_thumbImages) {
        _thumbImages = [NSMutableArray arrayWithCapacity:self.fetchResult.count];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        options.synchronous = YES;
        
        for (int i = 0; i < self.fetchResult.count; i++) {
            PHAsset *asset = self.fetchResult[i];
            if (asset.mediaType != PHAssetMediaTypeVideo) {
                
                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeZero contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * result, NSDictionary *info) {
                    [self.thumbImages addObject:result];
                }];
            }
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
