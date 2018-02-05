//
//  LiveInfoViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/6/16.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "LiveInfoViewController.h"
#import "LiveModel.h"
#import "UIImage+Tool.h"

@interface LiveInfoViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL showTitle;//导航栏是否完全显示

@end

@implementation LiveInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = [self tableHeaderView];
    [self.view addSubview:self.tableView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissInfoControler)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [self navigationBarColorClear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self navigationBarColorRestore];
}

#pragma mark
- (void)dismissInfoControler {
    if (self.LiveInfoDismissBlock) {
        self.LiveInfoDismissBlock();
    }
}

- (UIView *)tableHeaderView {
    CGFloat imageW = 100;
    CGFloat viewW = CGRectGetWidth(self.view.frame);
    CGFloat viewH = viewW * 0.5 + imageW * 0.5 + 60;
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewW, viewH)];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -viewW * 0.5, viewW, viewW)];
    [backgroundView sd_setImageWithURL:[NSURL URLWithString:self.liveModel.bigpic]];
    [tableHeaderView addSubview:backgroundView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageW, imageW)];
    imageView.center = CGPointMake(viewW * 0.5, viewW * 0.5);
    imageView.clipsToBounds = YES;
    imageView.layer.cornerRadius = imageW * 0.5;
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.liveModel.bigpic]];
    [tableHeaderView addSubview:imageView];
    
    UILabel *signaturesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10 + CGRectGetMaxY(imageView.frame), viewW, 30)];
    signaturesLabel.textAlignment = NSTextAlignmentCenter;
    signaturesLabel.font = [UIFont systemFontOfSize:16];
    signaturesLabel.text = self.liveModel.signatures.length ? self.liveModel.signatures : @"签名跑丢了";
    [tableHeaderView addSubview:signaturesLabel];
    
    UILabel *gpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(signaturesLabel.frame), viewW, 20)];
    gpsLabel.textAlignment = NSTextAlignmentCenter;
    gpsLabel.font = [UIFont systemFontOfSize:13];
    gpsLabel.text = self.liveModel.gps;
    [tableHeaderView addSubview:gpsLabel];
    
    return tableHeaderView;
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"暂无动态";
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY >= 64) {
        if (!_showTitle) {
            _showTitle = YES;
            self.title = self.liveModel.myname;
            [self navigationBarBackgroundImage:[UIImage imageWithColor:KBaseAppColor]];
        }
    } else if (offsetY < -Screen_W * 0.5) {
        scrollView.contentOffset = CGPointMake(0, -Screen_W * 0.5);
    } else {
        _showTitle = NO;
        self.title = nil;
        [self navigationBarBackgroundImage:[UIImage imageWithColor:KBaseAppColorAlpha(offsetY / 64.0)]];
    }
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 60;
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
