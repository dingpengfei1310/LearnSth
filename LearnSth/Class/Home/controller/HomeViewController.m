//
//  ViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "HomeViewController.h"
#import "WebViewController.h"

#import "BannerScrollView.h"
#import "HttpManager.h"
#import "ADModel.h"
#import "DeviceConfig.h"

@interface HomeViewController ()

@property (nonatomic, strong) NSArray *bannerList;
@property (nonatomic, strong) BannerScrollView *bannerScrollView;

@property (nonatomic, strong) NSMutableArray *viewArray;

@end

@implementation HomeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Home";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"00" style:UIBarButtonItemStylePlain target:self action:@selector(homeRightItemClick)];
    
    [self.view addSubview:self.bannerScrollView];
    [self getHomeAdBanner];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.bannerScrollView setUpTimer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.bannerScrollView invalidateTimer];
}

#pragma mark
- (void)getHomeAdBanner {
    [[HttpManager shareManager] getAdBannerListCompletion:^(NSArray *list, NSError *error) {
        
        if (error) {
            [self showErrorWithError:error];
        } else {
            NSArray *adArray = [ADModel adWithArray:list];
            self.bannerList = [[NSArray alloc] initWithArray:adArray copyItems:YES];;
            
            NSMutableArray *imageStringArray = [NSMutableArray arrayWithCapacity:self.bannerList.count];
            [self.bannerList enumerateObjectsUsingBlock:^(ADModel * obj, NSUInteger idx, BOOL * stop) {
                [imageStringArray addObject:obj.imageUrl];
            }];
            
            [self.bannerScrollView setImageArray:imageStringArray];
        }
    }];
}

- (void)homeRightItemClick {
}

#pragma mark
- (BannerScrollView *)bannerScrollView {
    if (!_bannerScrollView) {
        _bannerScrollView = [[BannerScrollView alloc] initWithFrame:CGRectMake(0, ViewFrame_X, Screen_W, Screen_W * 0.24)];
        
        __weak typeof(self) weakSelf = self;
        _bannerScrollView.imageClickBlock = ^(NSInteger index) {
            
            ADModel *model = weakSelf.bannerList[index];
            if (model.link.length > 0) {
                WebViewController *controller = [[WebViewController alloc] init];
                controller.hidesBottomBarWhenPushed = YES;
                controller.title = model.title;
                controller.urlString = model.link;
                [weakSelf.navigationController pushViewController:controller animated:YES];
            }
        };
    }
    
    return _bannerScrollView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

