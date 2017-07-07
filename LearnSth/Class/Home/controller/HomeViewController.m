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
    
    [self.view addSubview:self.liveCollectionView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(homeRightItemClick)];
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
//    backItem.title = @"";
//    self.navigationItem.backBarButtonItem = backItem;
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.liveCollectionView viewWillShow:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.liveCollectionView viewWillShow:NO];
}

- (void)homeRightItemClick {
//    SceneViewController *controller = [[SceneViewController alloc] init];
//    controller.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:controller animated:YES];
    
    JPuzzleViewController *controller = [[JPuzzleViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark
- (LiveCollectionView *)liveCollectionView {
    if (!_liveCollectionView) {
        __weak typeof(self) weakSelf = self;
        
        _liveCollectionView = [[LiveCollectionView alloc] initWithFrame:self.view.bounds];
        _liveCollectionView.BannerClickBlock = ^(NSString *link) {
            WebViewController *controller = [[WebViewController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            controller.urlString = link;
            [weakSelf.navigationController pushViewController:controller animated:YES];
        };
        
        _liveCollectionView.LiveClickBlock = ^(NSInteger index, NSArray *liveArray) {
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
    }
    return _liveCollectionView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
