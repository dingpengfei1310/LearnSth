//
//  UserViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UserViewController.h"
#import "PhotoLiarbraryController.h"
#import "LoginViewController.h"
#import "UserInfoViewController.h"
#import "FileScanViewController.h"
#import "SettingViewController.h"

#import "HeaderImageViewCell.h"
#import "UserManager.h"

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
    
    self.dataArray = @[@[@""],
                       @[@"相册",@"文件"],
                       @[@"设置"]
                       ];
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark
- (void)loginClick {
    if (![CustomiseTool isLogin]) {
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

#pragma mark
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.dataArray[section];
    return array.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setSeparatorInset:UIEdgeInsetsZero];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *reusableIdentifier = @"headerCell";
        HeaderImageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableIdentifier];
        if (!cell) {
            cell = [[HeaderImageViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reusableIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.userModel = [UserManager shareManager];
        cell.detailTextLabel.text = nil;
        if (![CustomiseTool isLogin]) {
            cell.detailTextLabel.text = @"请先登录";
        }
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        NSArray *array = self.dataArray[indexPath.section];
        cell.textLabel.text = array[indexPath.row];
        
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 70;
    } else {
        return 50;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [self loginClick];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self checkAuthorizationStatusOnPhotos];
        } else if (indexPath.row == 1) {
            FileScanViewController *controller = [[FileScanViewController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
        
    } else if (indexPath.section == 2) {
        SettingViewController *controller = [[SettingViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Screen_W, Screen_H) style:UITableViewStyleGrouped];
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
