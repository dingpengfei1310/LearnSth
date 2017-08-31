//
//  PhotoLibraryController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/11.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "PhotoLibraryController.h"
#import "PhotosCollectionController.h"
#import <Photos/Photos.h>

@interface PhotoLibraryController ()<UITableViewDataSource,UITableViewDelegate,PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PHFetchResult *smartAlbum;

@end

static NSString *Identifier = @"Cell";

@implementation PhotoLibraryController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"相册";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (self.LibraryDismissBlock) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissLibraryController)];
    }
    
    [self checkAuthorizationStatusOnPhotos];
}

- (void)checkAuthorizationStatusOnPhotos {
    PHAuthorizationStatus currentStatus = [PHPhotoLibrary authorizationStatus];
    if (currentStatus == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    [self initSubView];
                } else {
                    [self showError:@"没有访问权限"];
                }
            });
        }];
        
    } else if (currentStatus == PHAuthorizationStatusDenied) {
        [self showAuthorizationStatusDeniedAlertMessage:@"没有相机访问权限"];
        
    } else if (currentStatus == PHAuthorizationStatusAuthorized) {
        [self initSubView];
    }
}

- (void)initSubView {
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(getAllPhotosOrderByTime)];
    
    [self getSmartAlbum];
    [self.view addSubview:self.tableView];
    
    if (self.subtype != 0) {
        // 默认不会走到这里，除非指定了subtype
        PHAssetCollectionSubtype type = PHAssetCollectionSubtypeSmartAlbumUserLibrary;
        
        if (self.subtype == PhotoCollectionSubtypeImage) {
            type = PHAssetCollectionSubtypeSmartAlbumUserLibrary;
        } else if (self.subtype == PhotoCollectionSubtypeVideo) {
            type = PHAssetCollectionSubtypeSmartAlbumVideos;
        }
        
        PHAssetCollection *assetCollection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:type options:nil].firstObject;
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        
        PhotosCollectionController *controller = [[PhotosCollectionController alloc] init];
        controller.fetchResult = fetchResult;
        controller.title = assetCollection.localizedTitle;
        [self.navigationController pushViewController:controller animated:NO];
    }
}

- (void)dismissLibraryController {
    if (self.LibraryDismissBlock) {
        self.LibraryDismissBlock();
    }
}

#pragma mark
- (void)getSmartAlbum {
    // 列出所有智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
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
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    
    PhotosCollectionController *controller = [[PhotosCollectionController alloc] init];
    controller.fetchResult = assetsFetchResults;
    controller.title = @"我的照片";
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    DNSLog(@"photoLibraryDidChange");
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.smartAlbum.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier forIndexPath:indexPath];
    
    PHAssetCollection *assetCollection = self.smartAlbum[indexPath.row];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%ld)",assetCollection.localizedTitle,fetchResult.count];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PhotosCollectionController *controller = [[PhotosCollectionController alloc] init];
    PHAssetCollection *assetCollection = self.smartAlbum[indexPath.row];
    
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    controller.fetchResult = fetchResult;
    controller.title = assetCollection.localizedTitle;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        CGRect rect = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
        _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:Identifier];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

@end
