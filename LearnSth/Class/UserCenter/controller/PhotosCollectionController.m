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
#import "VideoScanController.h"

#import "PhotosCollectionCell.h"
#import "AnimatedTransitioning.h"

@interface PhotosCollectionController ()<UICollectionViewDataSource,UICollectionViewDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *thumbImages;//图片（不包括视频）

@property (nonatomic, assign) NSInteger selectIndex;//选中的index，包括视频，为了拿到frame做动画

@end

static NSString * const reuseIdentifier = @"Cell";
const CGFloat interitemSpacing = 5.0;
const NSInteger photoColumn = 4;

@implementation PhotosCollectionController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.collectionView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.delegate = nil;
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
    self.selectIndex = indexPath.row;
    self.navigationController.delegate = self;
    
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        
        if (self.scanType == VideoScanTypeNormal) {
            DDImageBrowserVideo *controller = [[DDImageBrowserVideo alloc] init];
            controller.asset = asset;
            [self.navigationController pushViewController:controller animated:YES];
        } else if (self.scanType == VideoScanTypeFilter) {
            VideoScanController *controller = [[VideoScanController alloc] init];
            controller.asset = asset;
            [self.navigationController pushViewController:controller animated:YES];
        }
        
    } else {
        
        DDImageBrowserController *controller = [[DDImageBrowserController alloc] init];
        controller.thumbImages = self.thumbImages;
        controller.currentIndex = [self calculateCurrentIndex:indexPath.row];
        controller.ScrollToIndexBlock = ^(DDImageBrowserController *controller, NSInteger index){
            __block int count = 0;
            [self.fetchResult enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL *stop) {
                if (obj.mediaType == PHAssetMediaTypeImage) {
                    if (count == index) {
                        [controller showHighQualityImageOfIndex:index WithAsset:obj];
                        *stop = YES;
                    }
                    count++;
                }
            }];
        };
        [self.navigationController pushViewController:controller animated:YES];
    }
}

//当前点击的照片index(已过滤视频)
- (NSInteger)calculateCurrentIndex:(NSInteger)row {
    int index = 0;
    for (int i = 0; i < row; i++) {
        PHAsset *tempAsset = self.fetchResult[i];
        if (tempAsset.mediaType == PHAssetMediaTypeImage) {
            index++;
        }
    }
    return index;
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

#pragma mark UINavigationControllerDelegate - UIViewControllerTransitioningDelegate
//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
//    return [[AnimatedTransitioning alloc] init];
//}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush){
        AnimatedTransitioning *transition = [[AnimatedTransitioning alloc] init];
        transition.operation = operation;
        transition.transitioningType = AnimatedTransitioningTypeScale;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectIndex inSection:0];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        CGRect rect = [self.collectionView convertRect:cell.frame toView:self.navigationController.view];
        transition.originalFrame = rect;
        
        return transition;
    }
    return nil;
}

#pragma mark
- (NSMutableArray *)thumbImages {
    if (!_thumbImages) {
        _thumbImages = [NSMutableArray array];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        options.synchronous = YES;
        
        [self.fetchResult enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL *stop) {
            if (obj.mediaType != PHAssetMediaTypeVideo) {
                
                [[PHImageManager defaultManager] requestImageForAsset:obj targetSize:CGSizeZero contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * result, NSDictionary *info) {
                    [self.thumbImages addObject:result];
                }];
            }
        }];
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
