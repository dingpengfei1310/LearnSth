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

@interface UserViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

static NSString *identifier = @"cell";

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"User";
    self.dataArray = @[@"上传文件",@"查看相册",@"消息"];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)
                                              style:UITableViewStylePlain];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 50;
    [self.view addSubview:_tableView];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadData:) forControlEvents:UIControlEventValueChanged];
    _tableView.refreshControl = refreshControl;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"defaultHeader"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)loadData:(UIRefreshControl *)refreshControl {
    [refreshControl endRefreshing];
    NSLog(@"loadData");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    }
    
}

#pragma mark
- (void)wifiUpload {
    WiFiUploadManager *manager = [WiFiUploadManager shareManager];
    BOOL success = [manager startHTTPServerAtPort:10000];
    
    if (success) {
        NSLog(@"URL = %@:%@",manager.ip,@(manager.port));
        NSLog(@"PATH = %@",manager.savePath);
        [[WiFiUploadManager shareManager] showWiFiPageViewController:self.navigationController];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
