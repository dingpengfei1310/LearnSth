//
//  ViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "HomeViewController.h"
#import "WebViewController.h"

#import "HttpManager.h"
#import "SDCycleScrollView.h"
#import "ADModel.h"

#import "AnimationView.h"

@interface HomeViewController ()<SDCycleScrollViewDelegate>

@property (nonatomic, strong) SDCycleScrollView *bannerView;
@property (nonatomic, strong) NSArray *bannerList;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"00" style:UIBarButtonItemStylePlain target:self action:@selector(homeRightItemClick)];
    
    _bannerView = [[SDCycleScrollView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenWidth * 300 / 1242)];
    _bannerView.delegate = self;
    [self.view addSubview:_bannerView];
    
//    AnimationView *aView = [[AnimationView alloc] initWithFrame:CGRectMake((ScreenWidth - 170) * 0.5, CGRectGetMaxY(_bannerView.frame) + 20, 170, 100)];
//    aView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:aView];
    
//    LineView *aView = [[LineView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_bannerView.frame) + 20, ScreenWidth, 200)];
//    [self.view addSubview:aView];
    
    [self getHomeAdBanner];
    
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
            NSArray *banners = [ADModel adWithArray:list];
            self.bannerList = banners;
            
            NSMutableArray *imageStringArray = [NSMutableArray arrayWithCapacity:banners.count];
            [banners enumerateObjectsUsingBlock:^(ADModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [imageStringArray addObject:obj.imageUrl];
            }];
            
            [_bannerView setImageURLStringsGroup:imageStringArray];
        }
    }];
    
}

- (void)homeRightItemClick {
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    ADModel *model = self.bannerList[index];
    
    if (model.link.length > 0) {
        WebViewController *controller = [[WebViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        controller.title = model.title;
        controller.urlString = model.link;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
