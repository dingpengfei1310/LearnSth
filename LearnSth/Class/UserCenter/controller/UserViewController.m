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

#import "AppDelegate.h"
#import "TabBarViewController.h"

#import "HttpManager.h"
#import "WiFiUploadManager.h"
#import <Photos/PHPhotoLibrary.h>
#import <AVFoundation/AVFoundation.h>

@interface UserViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

static NSString *identifier = @"cell";

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"🏓🏓🏓";
    
    self.dataArray = @[@"上传文件",
                       @"查看相册",
                       @"消息",
                       @"清除缓存",
                       @"查看本机文件",
                       DDNSLocalizedGetString(@"Language")];
    [self.view addSubview:self.tableView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"defaultHeader"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

#pragma mark
- (void)loginClick {
    if (![Utils isLogin]) {
        LoginViewController *controller = [[LoginViewController alloc] init];
        controller.DismissBlock = ^ {
            [self dismissViewControllerAnimated:YES completion:nil];
        };
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
    [self showAlertWithTitle:@"提示" message:@"确定要清除缓存吗" cancel:nil destructive:^{
        [self clearDiskCache];
    }];
}

- (void)clearDiskCache {
    [self loading];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [Utils clearCacheAtPath:KCachePath];
        
        dispatch_async(dispatch_get_main_queue(),^{
            [self hideHUD];
            [self.tableView reloadData];
        });
        
    });
}

- (CGFloat)calculateDiskCacheSize {
    long long longSize = [Utils folderSizeAtPath:KCachePath];
    CGFloat cacheSize = longSize / 1024.0 / 1024.0;
//    NSLog(@"%@",kCachePath);
    
    return cacheSize;
}

//检查权限－相册
- (void)checkAuthorizationStatusOnPhotos {
    PHAuthorizationStatus currentStatus = [PHPhotoLibrary authorizationStatus];
    if (currentStatus == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    PhotoLiarbraryController *controller = [[PhotoLiarbraryController alloc] init];
                    controller.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:controller animated:YES];
                }
            });
        }];
        
    } else if (currentStatus == PHAuthorizationStatusDenied) {
        [self showAuthorizationStatusDeniedAlertMessage:@"没有相机访问权限" cancel:nil operation:nil];
        
    } else if (currentStatus == PHAuthorizationStatusAuthorized) {
        PhotoLiarbraryController *controller = [[PhotoLiarbraryController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)changeLanguage:(NSString *)language {
    [[LanguageTool shareInstance] changeLanguage:language];
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    TabBarViewController *controller = [[TabBarViewController alloc] init];
    [controller setSelectedIndex:1];
    app.window.rootViewController = controller;
    
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
        [self checkAuthorizationStatusOnPhotos];
        
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
        
    } else if (indexPath.row == 5) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:DDNSLocalizedGetString(@"ChangeLanguage") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *en = [UIAlertAction actionWithTitle:DDNSLocalizedGetString(@"English")
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self changeLanguage:@"en"];
                                                   }];
        UIAlertAction *zh = [UIAlertAction actionWithTitle:DDNSLocalizedGetString(@"Chinese")
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self changeLanguage:@"zh-Hans"];
                                                   }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:DDNSLocalizedGetString(@"Cancel")
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
        
        [actionSheet addAction:en];
        [actionSheet addAction:zh];
        [actionSheet addAction:cancel];
        
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ViewFrame_X, Screen_W, Screen_H) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 50;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
