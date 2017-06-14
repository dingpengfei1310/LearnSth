//
//  SettingViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/14.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "SettingViewController.h"
#import "RootViewController.h"
#import "MessageViewController.h"
#import "DownloadViewController.h"
#import "FileScanViewController.h"

#import "WiFiUploadManager.h"
#import "UserManager.h"

#import <Photos/Photos.h>

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    
    self.dataArray = @[@"消息",
                       @"我的下载",
                       @"本机文件",
                       @"清除缓存",
                       @"语言"];
    [self.view addSubview:self.tableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(wifiUpload)];
}

#pragma mark
- (void)wifiUpload {
    WiFiUploadManager *manager = [WiFiUploadManager shareManager];
    BOOL success = [manager startHTTPServerAtPort:10000];
    
    if (success) {
        NSLog(@"URL = %@:%@",manager.ip,@(manager.port));
        [[WiFiUploadManager shareManager] showWiFiPageViewController:self];
    }
}

- (void)showAlertOnClearDiskCache {
    [self showAlertWithTitle:nil message:@"确定要清除缓存吗" cancel:nil destructive:^{
        [self clearDiskCache];
    }];
}

- (void)clearDiskCache {
    [self loading];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [CustomiseTool clearCacheAtPath:KCachePath];
        
        dispatch_async(dispatch_get_main_queue(),^{
            [self hideHUD];
            [self.tableView reloadData];
        });
    });
}

- (CGFloat)calculateDiskCacheSize {
    long long longSize = [CustomiseTool folderSizeAtPath:KCachePath];
    CGFloat cacheSize = longSize / 1024.0 / 1024.0;
    return cacheSize;
}

- (void)changeLanguage:(LanguageType)type {
    if ([CustomiseTool languageType] != type) {
        [self loading];
        
        [CustomiseTool changeLanguage:type oncompletion:^{
            [self hideHUD];
            
            RootViewController *controller = (RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            [controller loadViewControllersWithSelectIndex:2];
        }];
    }
}

- (void)logOut {
    [self showAlertWithTitle:nil message:@"确定要退出登录吗" cancel:nil destructive:^{
        [CustomiseTool remoAllCaches];
        [UserManager deallocManager];
        
        if (self.LogoutBlock) {
            self.LogoutBlock();
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.detailTextLabel.text = nil;
    
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        MessageViewController *controller = [[MessageViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if (indexPath.row == 1) {
        DownloadViewController *controller = [[DownloadViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if (indexPath.row == 2) {
        FileScanViewController *controller = [[FileScanViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if (indexPath.row == 3) {
        [self showAlertOnClearDiskCache];
        
    } else if (indexPath.row == 4) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:DLocalizedString(@"切换语言") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *en = [UIAlertAction actionWithTitle:DLocalizedString(@"英语")
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self changeLanguage:LanguageTypeEn];
                                                   }];
        UIAlertAction *zh = [UIAlertAction actionWithTitle:DLocalizedString(@"简体中文")
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self changeLanguage:LanguageTypeZH];
                                                   }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:DLocalizedString(@"取消")
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
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 50;
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.layoutMargins = UIEdgeInsetsZero;
        
        if ([CustomiseTool isLogin]) {
            UIButton *logoutButon = [UIButton buttonWithType:UIButtonTypeSystem];
            logoutButon.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
            logoutButon.backgroundColor = [UIColor whiteColor];
            [logoutButon setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [logoutButon setTitle:@"退出登录" forState:UIControlStateNormal];
            [logoutButon addTarget:self action:@selector(logOut) forControlEvents:UIControlEventTouchUpInside];
            _tableView.tableFooterView = logoutButon;
        }
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
