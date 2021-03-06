//
//  HomeViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "HomeViewController.h"
#import "WebViewController.h"
#import "PLPlayerViewController.h"
#import "JPuzzleViewController.h"

#import "LiveCollectionView.h"

@interface HomeViewController ()

@property (nonatomic, strong) LiveCollectionView *liveCollectionView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"首页";
    
    CGFloat barH = NavigationBarH + StatusBarH;
    CGRect frame = CGRectMake(0, barH, Screen_W, Screen_H - barH - TabBarH);
    
    self.liveCollectionView = [[LiveCollectionView alloc] initWithFrame:frame];
    self.liveCollectionView.hidden = YES;
    [self.view addSubview:self.liveCollectionView];
    
    __weak typeof(self) weakSelf = self;
    self.liveCollectionView.BannerClickBlock = ^(NSString *link, NSString *title) {
        WebViewController *controller = [[WebViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        controller.title = title;
        controller.urlString = link;
        [weakSelf.navigationController pushViewController:controller animated:YES];
    };
    
    self.liveCollectionView.LiveClickBlock = ^(NSInteger index, NSArray *liveArray) {
        PLPlayerViewController *controller = [[PLPlayerViewController alloc] init];
        controller.PlayerDismissBlock = ^{
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        };
        controller.index = index;
        controller.liveArray = liveArray;
        controller.hidesBottomBarWhenPushed = YES;
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:controller];
        [weakSelf presentViewController:nvc animated:YES completion:nil];
    };
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"  " style:UIBarButtonItemStylePlain target:self action:@selector(leftItemClick)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(homeRightItemClick)];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.liveCollectionView viewWillShow:YES];
    
    if ([CustomiseTool isNightModel]) {
        self.liveCollectionView.backgroundColor = [UIColor blackColor];
    } else {
        self.liveCollectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.liveCollectionView viewWillShow:NO];
}

#pragma mark
- (void)homeRightItemClick {
    JPuzzleViewController *controller = [[JPuzzleViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)leftItemClick {
    self.liveCollectionView.hidden = !self.liveCollectionView.hidden;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
