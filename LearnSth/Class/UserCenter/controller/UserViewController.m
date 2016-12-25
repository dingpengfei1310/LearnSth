//
//  UserViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UserViewController.h"

#import "PhotoLiarbraryController.h"
#import "MessageViewController.h"
#import "LoginViewController.h"
#import "UserInfoViewController.h"
#import "FileScanViewController.h"

#import "HttpManager.h"
#import "WiFiUploadManager.h"

@interface UserViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UIImageView *topImageView;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *dataArray;

@end

static NSString *identifier = @"cell";

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"User";
    
    [self.view addSubview:self.topImageView];
    self.dataArray = @[@"上传文件",@"查看相册",@"消息",@"清除缓存",@"查看本机文件"];
    [self.view addSubview:self.tableView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"defaultHeader"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

#pragma mark
- (void)refreshData:(UIRefreshControl *)refreshControl {
    [refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (void)loginClick {
    if (![Utils isLogin]) {
        LoginViewController *controller = [[LoginViewController alloc] init];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:nvc animated:YES completion:nil];
    } else {
        UserInfoViewController *controller = [[UserInfoViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)wifiUpload {
    WiFiUploadManager *manager = [WiFiUploadManager shareManager];
    BOOL success = [manager startHTTPServerAtPort:10000];
    
    if (success) {
        NSLog(@"URL = %@:%@",manager.ip,@(manager.port));
        NSLog(@"PATH = %@",manager.savePath);
        [[WiFiUploadManager shareManager] showWiFiPageViewController:self.navigationController];
    }
}

- (void)showAlertOnClearDiskCache {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定要清除缓存吗" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertAction *certainAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self clearDiskCache];
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:certainAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)clearDiskCache {
    [self showMessage:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [Utils clearCacheAtPath:kCachePath];
        
        dispatch_async(dispatch_get_main_queue(),^{
            [self hideHUD];
            [self.tableView reloadData];
        });
        
    });
}

- (CGFloat)calculateDiskCacheSize {
    long long longSize = [Utils folderSizeAtPath:kCachePath];
    CGFloat cacheSize = longSize / 1024.0 / 1024.0;
//    NSLog(@"%@",kCachePath);
    
    return cacheSize;
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    if (indexPath.row == 3) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            CGFloat cacheSize = [self calculateDiskCacheSize];
            
            dispatch_async(dispatch_get_main_queue(),^{
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fM",cacheSize];
            });
            
        });
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        
        [self wifiUpload];
        
    } else if (indexPath.row == 1) {
        
        PhotoLiarbraryController *controller = [[PhotoLiarbraryController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if (indexPath.row == 2) {
        
        MessageViewController *controller = [[MessageViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if (indexPath.row == 3) {
        
        [self showAlertOnClearDiskCache];
        
    } else if (indexPath.row == 4) {
        
        FileScanViewController *controller = [[FileScanViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat scale = 1 - (scrollView.contentOffset.y / 200);
//    scale = (scale >= 1) ? scale : 1;
//    
//    self.topImageView.transform = CGAffineTransformMakeScale(scale, scale);
//}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStylePlain];
        CGFloat topHeight = ScreenWidth * 0.5;
        _tableView.frame= CGRectMake(0, ViewFrameOrigin_X + topHeight, ScreenWidth, ScreenHeight - 64 - topHeight);
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 60;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        
        _tableView.tableFooterView = [[UIView alloc] init];
        
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
        _tableView.refreshControl = refreshControl;
        
    }
    return _tableView;
}

- (UIImageView *)topImageView {
    if (!_topImageView) {
        _topImageView = [[UIImageView alloc] init];
        _topImageView.frame = CGRectMake(0, ViewFrameOrigin_X, ScreenWidth, ScreenWidth * 43 / 75);
        _topImageView.image = [UIImage imageNamed:@"defaultBackground"];
    }
    
    return _topImageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

