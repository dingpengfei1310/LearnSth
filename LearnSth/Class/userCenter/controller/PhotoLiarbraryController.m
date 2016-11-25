//
//  PhotoLiarbraryTableViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/11.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "PhotoLiarbraryController.h"
#import "PhotosViewController.h"

#import <Photos/Photos.h>

@interface PhotoLiarbraryController ()<UITableViewDataSource,UITableViewDelegate,PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *nameList;
@property (nonatomic, strong) NSArray *typeList;

@property (nonatomic, strong) NSMutableArray *albumList;

@property (nonatomic, strong) PHFetchResult *smartAlbum;
@end

static NSString * const reuseIdentifier = @"Cell";

@implementation PhotoLiarbraryController

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)
                                                  style:UITableViewStylePlain];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    PHAuthorizationStatus currentStatus = [PHPhotoLibrary authorizationStatus];
    
    if (currentStatus == PHAuthorizationStatusNotDetermined) {
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self checkAuthorizationStatusWith:(status == PHAuthorizationStatusAuthorized ? YES : NO)];
            });
        }];
        
    } else if (currentStatus == PHAuthorizationStatusDenied || currentStatus == PHAuthorizationStatusRestricted) {
        
        [self checkAuthorizationStatusWith:NO];
        
    } else if (currentStatus == PHAuthorizationStatusAuthorized) {
        
        [self checkAuthorizationStatusWith:YES];
    }
}

- (void)checkAuthorizationStatusWith:(BOOL)status {
    if (status) {
        self.nameList = @[@"相机胶卷",@"我的照片流",@"视频",@"最近添加",@"屏幕快照"];
        
        self.typeList = @[
                          @(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                          @(PHAssetCollectionSubtypeAlbumMyPhotoStream),
                          @(PHAssetCollectionSubtypeSmartAlbumVideos),
                          @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),
                          @(PHAssetCollectionSubtypeSmartAlbumScreenshots)
                          ];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(getAllPhotosOrderByTime)];
        
        if (TARGET_OS_SIMULATOR) {
            [self getSmartAlbum];
        }
        
        self.albumList = [NSMutableArray arrayWithCapacity:self.nameList.count];
        [self.view addSubview:self.tableView];
        
    } else {
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ScreenHeight * 0.2, ScreenWidth, 30)];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.text = @"请打开权限";
        [self.view addSubview:tipLabel];
    }
    
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    NSLog(@"photoLibraryDidChange");
}

#pragma mark
- (void)getSmartAlbum {
    // 列出所有智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                          subtype:PHAssetCollectionSubtypeAlbumRegular
                                                                          options:nil];
    
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
    
    PhotosViewController *controller = [[PhotosViewController alloc] init];
    controller.fetchResult = assetsFetchResults;
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.smartAlbum) {
        return self.smartAlbum.count;
    }
    return self.nameList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (self.smartAlbum) {
        
        PHAssetCollection *assetCollection = self.smartAlbum[indexPath.row];
        
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@(%ld)",assetCollection.localizedTitle,fetchResult.count];
        
        return cell;
    } else {
        NSInteger subType = [self.typeList[indexPath.row] integerValue];
        PHFetchResult *smartAlbums;
        if (indexPath.row == 1) {
            //照片流
            smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                   subtype:subType
                                                                   options:nil];
        } else {
            smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                   subtype:subType
                                                                   options:nil];
        }
        
        PHFetchResult *fetchResult;
        
        if (smartAlbums.count > 0) {
            PHAssetCollection *assetCollection = smartAlbums[0];
            // 从每一个智能相册中获取到的 PHFetchResult 中包含的才是真正的资源（PHAsset）
            fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
            
            self.albumList[indexPath.row] = fetchResult;
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@(%ld)",self.nameList[indexPath.row],fetchResult.count];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PhotosViewController *controller = [[PhotosViewController alloc] init];
    if (self.smartAlbum) {
        PHAssetCollection *assetCollection = self.smartAlbum[indexPath.row];
        controller.assetCollection = assetCollection;
    } else {
        controller.fetchResult = self.albumList[indexPath.row];
    }
    
    [self.navigationController pushViewController:controller animated:YES];
    
}


@end

