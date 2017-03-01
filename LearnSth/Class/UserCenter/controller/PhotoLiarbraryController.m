//
//  PhotoLiarbraryTableViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/11.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "PhotoLiarbraryController.h"
#import "PhotosCollectionController.h"
#import <Photos/Photos.h>

@interface PhotoLiarbraryController ()<UITableViewDataSource,UITableViewDelegate,PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PHFetchResult *smartAlbum;

@end

static NSString * const reuseIdentifier = @"Cell";

@implementation PhotoLiarbraryController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的相册";
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(getAllPhotosOrderByTime)];
    
//    if (TARGET_OS_SIMULATOR) {
//    }
    
    [self getSmartAlbum];
    [self.view addSubview:self.tableView];
}

#pragma mark
- (void)getSmartAlbum {
    // 列出所有智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
//    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    
    self.smartAlbum = smartAlbums;
}

- (void)getUserAlbum {
    // 列出所有用户创建的相册
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    self.smartAlbum = topLevelUserCollections;
}

- (void)getAllPhotosOrderByTime {
    // 获取所有资源的集合，并按资源的创建时间排序
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    
    PhotosCollectionController *controller = [[PhotosCollectionController alloc] init];
    controller.fetchResult = assetsFetchResults;
    controller.title = @"我的照片";
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    NSLog(@"photoLibraryDidChange");
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.smartAlbum.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    PHAssetCollection *assetCollection = self.smartAlbum[indexPath.row];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%ld)",assetCollection.localizedTitle,fetchResult.count];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PhotosCollectionController *controller = [[PhotosCollectionController alloc] init];
    PHAssetCollection *assetCollection = self.smartAlbum[indexPath.row];
    
//    controller.assetCollection = assetCollection;
    
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    controller.fetchResult = fetchResult;
    
    controller.title = assetCollection.localizedTitle;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Screen_W, Screen_H) style:UITableViewStylePlain];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
