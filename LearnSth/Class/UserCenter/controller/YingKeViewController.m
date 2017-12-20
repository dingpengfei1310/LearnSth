//
//  YingKeViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/12/20.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "YingKeViewController.h"
#import "WebViewController.h"
#import "YingKeLiveModel.h"

@interface YingKeViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

static NSString *reuseIdentifier = @"cell";

@implementation YingKeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    [[HttpManager shareManager] getYingKeLiveListCompletion:^(NSArray *list, NSError *error) {
        if (!error) {
            self.dataArray = [YingKeLiveModel liveWithArray:list];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    YingKeLiveModel *info = self.dataArray[indexPath.row];
    cell.textLabel.text = info.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YingKeLiveModel *info = self.dataArray[indexPath.row];
    
    WebViewController *controller = [[WebViewController alloc] init];
//    controller.title = title;
    controller.urlString = info.share_addr;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        CGFloat barH = NavigationBarH + StatusBarH;
        CGRect frame = CGRectMake(0, barH, Screen_W, Screen_H - barH);
        
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
        
        _tableView.backgroundColor = KBackgroundColor;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 50;
        _tableView.estimatedRowHeight = 0;
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
