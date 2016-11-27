//
//  UserViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UserViewController.h"

#import "WiFiUploadManager.h"

#import "PhotoLiarbraryController.h"
#import "MessageViewController.h"

#import "LoginViewController.h"
#import "UserInfoViewController.h"

#import "HttpManager.h"

@interface UserViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

static NSString *identifier = @"cell";

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"User";
    
    self.dataArray = @[@"上传文件",@"查看相册",@"消息",@"本地通知"];
    [self.view addSubview:self.tableView];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadData:) forControlEvents:UIControlEventValueChanged];
    _tableView.refreshControl = refreshControl;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"defaultHeader"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#pragma mark
- (void)loadData:(UIRefreshControl *)refreshControl {
    [refreshControl endRefreshing];
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

- (void)userLocationNotifications {
    UIUserNotificationSettings *currentSettings =  [UIApplication sharedApplication].currentUserNotificationSettings;
    
    if (![Utils haveChooseUserNotification] || currentSettings.types != UIUserNotificationTypeNone) {
        
        if (![Utils haveChooseUserNotification]) {
            UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge;
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                     categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        }
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertTitle = @"alertTitle";
        localNotification.alertBody = @"alertBody";
        
        NSDictionary *userInfo = @{@"message":@"老师开发建设的房间里看到手机发呆就是封疆大吏舒服"};
        localNotification.userInfo = userInfo;
        
        NSDate *now = [NSDate date];
        NSDate *fireDate = [NSDate dateWithTimeInterval:10 sinceDate:now];
        localNotification.fireDate = fireDate;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
    } else {
        [self showError:@"您已关闭通知，请到设置里打开"];
    }
    
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    
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
        
        [self userLocationNotifications];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)
                                                  style:UITableViewStylePlain];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 50;
        
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    }
    return _tableView;
}


@end
