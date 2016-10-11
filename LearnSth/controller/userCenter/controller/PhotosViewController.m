//
//  PhotosCollectionViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/11.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "PhotosViewController.h"

@interface PhotosViewController ()<UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation PhotosViewController

static NSString * const reuseIdentifier = @"Cell";

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
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (ScreenWidth - 50) / 4, (ScreenWidth - 50) / 4)];
    [cell.contentView addSubview:imageView];
//    CGSizeMake((ScreenWidth - 50) / 4, (ScreenWidth - 50) / 4)
//    PHImageManagerMaximumSize
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:PHImageManagerMaximumSize
                                              contentMode:PHImageContentModeAspectFit
                                                  options:nil
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                imageView.image = result;
                                            }];
    
    
    return cell;
}



@end
