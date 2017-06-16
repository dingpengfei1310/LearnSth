//
//  LiveInfoViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/6/16.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "LiveInfoViewController.h"
#import "LiveModel.h"

@interface LiveInfoViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LiveInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.liveModel.familyName;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGFloat viewW = CGRectGetWidth(self.view.frame);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewW, viewW)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.liveModel.bigpic]];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithFrame:imageView.bounds];
    effectView.effect = blurEffect;
    [imageView addSubview:effectView];
    
    self.tableView.tableHeaderView = imageView;
    [self.view addSubview:self.tableView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissInfoControler)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [self navigationBarColorClear];
}

- (void)dismissInfoControler {
    if (self.LiveInfoDismissBlock) {
        self.LiveInfoDismissBlock();
    }
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"0123";
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY < 0) {
        scrollView.contentOffset = CGPointMake(0, 0);
        
    } else if (offsetY < 64) {
        [self navigationBarBackgroundImage:[UIColor colorWithWhite:1.0 alpha:offsetY / 64.0]];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        
    } else if(offsetY < 74) {
        [self navigationBarBackgroundImage:[UIColor whiteColor]];
        self.navigationController.navigationBar.tintColor = KBaseBlueColor;
        
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    }
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 50;
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
