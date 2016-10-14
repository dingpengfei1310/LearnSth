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

@property (nonatomic, strong) NSArray *nameList;
@property (nonatomic, strong) NSArray *typeList;

@property (nonatomic, strong) NSMutableArray *fetchResult;

@property (nonnull, strong) PHFetchResult *result;
@end

static NSString * const reuseIdentifier = @"Cell";

@implementation PhotoLiarbraryViewController

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
                          @(PHAssetCollectionSubtypeAlbumRegular),
                          @(PHAssetCollectionSubtypeSmartAlbumVideos),
                          @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),
                          @(PHAssetCollectionSubtypeSmartAlbumScreenshots)
                          ];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(getAllPhotosOrderByTime)];
        
//        [self getUserAlbum];
        
        self.fetchResult = [NSMutableArray arrayWithCapacity:self.nameList.count];
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
- (void)getAllAlbum {
    // 列出所有智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
//    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    
    self.result = smartAlbums;
}

- (void)getUserAlbum {
    // 列出所有用户创建的相册
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    self.result = topLevelUserCollections;
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

#pragma mark - 保存照片到新建相册
- (PHFetchResult<PHAsset *> *)createAssets {
    UIImage *image = [UIImage imageNamed:@"lookup"];
    
    __block NSString *createdAssetId = nil;
    // 添加图片到【相机胶卷】
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:nil];
    // 在保存完毕后取出图片
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];
}

- (PHAssetCollection *)createAssetCollection {
    // 获取软件的名字作为相册的标题(如果需求不是要软件名称作为相册名字就可以自己把这里改成想要的名称)
    NSString *title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
//    NSString *title = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
    // 获得所有的自定义相册
    PHFetchResult *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:title]) {
            return collection;
        }
    }
    // 代码执行到这里，说明还没有自定义相册
    __block NSString *createdCollectionId = nil;
    // 创建一个新的相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdCollectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
    } error:nil];
    
    // 创建完毕后再取出相册
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCollectionId] options:nil].firstObject;
}

//保存图片到相册
-(void)saveImageIntoAlbum {
    // 获得相片
    PHFetchResult<PHAsset *> *createdAssets = [self createAssets];
    // 获得相册
    PHAssetCollection *createdCollection = [self createAssetCollection];
    
    if (createdAssets == nil || createdCollection == nil) {
        NSLog(@"%@",@"保存失败");
        return;
    }
    // 将相片添加到相册
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
        [request insertAssets:createdAssets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    // 保存结果
    if (error) {
        NSLog(@"%@",@"保存失败");
    } else {
        NSLog(@"%@",@"保存成功");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.result) {
        return self.result.count;
    }
    return self.nameList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (self.result) {
        
        PHAssetCollection *assetCollection = self.result[indexPath.row];
        
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@(%ld)",assetCollection.localizedTitle,fetchResult.count];
        
        return cell;
    } else {
        NSInteger subType = [self.typeList[indexPath.row] integerValue];
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:subType options:nil];
        
        PHFetchResult *fetchResult;
        
        if (smartAlbums.count > 0) {
            PHAssetCollection *assetCollection = smartAlbums[0];
            // 从每一个智能相册中获取到的 PHFetchResult 中包含的才是真正的资源（PHAsset）
            fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
            self.fetchResult[indexPath.row] = fetchResult;
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@(%ld)",self.nameList[indexPath.row],fetchResult.count];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PhotosViewController *controller = [[PhotosViewController alloc] init];
    if (self.result) {
        PHAssetCollection *assetCollection = self.result[indexPath.row];
        controller.assetCollection = assetCollection;
    } else {
        controller.fetchResult = self.fetchResult[indexPath.row];
    }
    
    [self.navigationController pushViewController:controller animated:YES];
    
}


@end

