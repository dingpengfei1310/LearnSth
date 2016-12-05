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

#import "AnimationView.h"

#import "UIImageView+WebCache.h"


@interface HomeViewController ()

@property (nonatomic, copy) NSArray *bannerList;

@property (nonatomic, strong) BannerScrollView *bannerScrollView;

@end

@implementation HomeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"00" style:UIBarButtonItemStylePlain target:self action:@selector(homeRightItemClick)];
    
    [self.view addSubview:self.bannerScrollView];
    [self getHomeAdBanner];
    
//    AnimationView *aView = [[AnimationView alloc] initWithFrame:CGRectMake((ScreenWidth - 170) * 0.5, CGRectGetMaxY(_bannerView.frame) + 20, 170, 100)];
//    aView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:aView];
    
//    LineView *aView = [[LineView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_bannerView.frame) + 20, ScreenWidth, 200)];
//    [self.view addSubview:aView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#pragma mark
- (void)getHomeAdBanner {
    [self loading];
    
    [[HttpManager shareManager] getAdBannerListCompletion:^(NSArray *list, NSError *error) {
        [self hideHUD];
        
        if (error) {
            [self showErrorWithError:error];
        } else {
            NSArray *adArray = [ADModel adWithArray:list];
            self.bannerList = [[NSArray alloc] initWithArray:adArray copyItems:YES];;
            
            NSMutableArray *imageStringArray = [NSMutableArray arrayWithCapacity:self.bannerList.count];
            [self.bannerList enumerateObjectsUsingBlock:^(ADModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [imageStringArray addObject:obj.imageUrl];
            }];
            
            [_bannerScrollView setImageArray:imageStringArray];
        }
    }];
}

- (void)homeRightItemClick {
    
}

#pragma mark
- (BannerScrollView *)bannerScrollView {
    if (!_bannerScrollView) {
        _bannerScrollView = [[BannerScrollView alloc] initWithFrame:CGRectMake(0, ViewFrameOrigin_X, ScreenWidth, ScreenWidth * 0.24)];
        
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
