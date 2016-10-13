//
//  PhotoLiarbraryTableViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/11.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "PhotoLiarbraryViewController.h"
#import "PhotosViewController.h"

#import <Photos/Photos.h>

@interface PhotoLiarbraryViewController ()<UITableViewDataSource,UITableViewDelegate,PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PHFetchResult *fetchResult;

@end

static NSString * const reuseIdentifier = @"Cell";

@implementation PhotoLiarbraryViewController

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)
                                                  style:UITableViewStylePlain];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 44;
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
            [self checkAuthorizationStatusWith:(status == PHAuthorizationStatusAuthorized ? YES : NO)];
        }];
        
    } else if (currentStatus == PHAuthorizationStatusDenied || currentStatus == PHAuthorizationStatusRestricted) {
        
        [self checkAuthorizationStatusWith:NO];
        
    } else if (currentStatus == PHAuthorizationStatusAuthorized) {
        
        [self checkAuthorizationStatusWith:YES];
        
    }
    
}

- (void)checkAuthorizationStatusWith:(BOOL)status {
    if (status) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(getAllPhotosOrderByTime)];
        
        [self getAllAlbum];
        [self.view addSubview:self.tableView];
        
    } else {
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ScreenHeight * 0.2, ScreenWidth, 30)];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.text = @"请打开权限";
        [self.view addSubview:tipLabel];
    }
    
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    
}

#pragma mark
- (void)getAllAlbum {
    // 列出所有智能相册
//    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
//    self.fetchResult = smartAlbums;
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    self.fetchResult = smartAlbums;
}

- (void)getUserAlbum {
    // 列出所有用户创建的相册
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    self.fetchResult = topLevelUserCollections;
    
}

- (void)getAllPhotosOrderByTime {
    // 获取所有资源的集合，并按资源的创建时间排序
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    
    PhotosViewController *controller = [[PhotosViewController alloc] init];
    controller.fetchResult = assetsFetchResults;
    
    [self.navigationController pushViewController:controller animated:YES];
    
//    [self createAlbum];
}

- (void)createAlbum {
//    let fetchResult = PHCollection.fetchCollectionsInCollectionList(collectionList, options: nil)
//    let createSubAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(title!)
//    let albumPlaceholder = createSubAlbumRequest.placeholderForCreatedAssetCollection
//    let folderChangeRequest = PHCollectionListChangeRequest.init(forCollectionList: collectionList, childCollections: fetchResult)
//    folderChangeRequest?.addChildCollections([albumPlaceholder])
    
    
//    [PHCollection fetchCollectionsInCollectionList:<#(nonnull PHCollectionList *)#> options:<#(nullable PHFetchOptions *)#>];
    
//    [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"新相册"];
    
    UIImage *image = [UIImage imageNamed:@"lookup"];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchResult.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    PHAssetCollection *assetCollection = self.fetchResult[indexPath.row];
    
    cell.textLabel.text = assetCollection.localizedTitle;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PhotosViewController *controller = [[PhotosViewController alloc] init];
    
    PHAssetCollection *assetCollection = self.fetchResult[indexPath.row];
    controller.assetCollection = assetCollection;
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end



