//
//  PhotosCollectionViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/11.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "PhotosViewController.h"
#import "DDImageBrowserView.h"

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
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumInteritemSpacing = 10;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)
                                         collectionViewLayout:flowLayout];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.contentInset = UIEdgeInsetsMake(10, 10, 0, 10);
    
    [self.view addSubview:_collectionView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    PHAsset *asset = self.fetchResult[indexPath.row];
    
    CGSize itemSize = CGSizeMake((ScreenWidth - 50) / 4, (ScreenWidth - 50) / 4);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, itemSize.width, itemSize.height)];
    [cell.contentView addSubview:imageView];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.synchronous = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:CGSizeMake(itemSize.width * 2, itemSize.height * 2)
                                              contentMode:PHImageContentModeAspectFit
                                                  options:nil
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                imageView.image = result;
                                                self.thumbImages[indexPath.row] = result;
                                            }];
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDImageBrowserView *imageBrowserView = [[DDImageBrowserView alloc] initWithFrame:self.view.window.bounds];
    imageBrowserView.imageBrowserDelegate = self;
    imageBrowserView.imageCount = self.fetchResult.count;
    [imageBrowserView selectImageOfIndex:indexPath.item];
    [imageBrowserView show];
}

#pragma mark - DDImageBrowserDelegate
- (UIImage *)imageBrowser:(DDImageBrowserView *)imageBrowser placeholderImageOfIndex:(NSInteger)index {
    UIImage *image = self.thumbImages[index];
    NSLog(@"%@",[NSValue valueWithCGSize:image.size]);
    return self.thumbImages[index];
}

- (void)imageBrowser:(DDImageBrowserView *)imageBrowser didScrollToIndex:(NSInteger)index {
    PHAsset *asset = self.fetchResult[index];
    
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:PHImageManagerMaximumSize
                                              contentMode:PHImageContentModeAspectFit
                                                  options:nil
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                [imageBrowser setImageOfIndex:index withImage:result];
                                            }];
}

@end



