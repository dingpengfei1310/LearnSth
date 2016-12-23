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

#import "UIButton+Tool.h"

@interface HomeViewController ()

@property (nonatomic, strong) NSArray *bannerList;
@property (nonatomic, strong) BannerScrollView *bannerScrollView;

@property (nonatomic, strong) UIButton *button;

@end

@implementation HomeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Home";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"00" style:UIBarButtonItemStylePlain target:self action:@selector(homeRightItemClick)];
    
    [self.view addSubview:self.bannerScrollView];
    [self getHomeAdBanner];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = KBaseBlueColor;
    button.frame = CGRectMake(20, 200, 100, 100);
    [self.view addSubview:button];
    
    UIImage *image = [[UIImage imageNamed:@"reflesh1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [button setImage:image forState:UIControlStateNormal];
    
    [button setTitle:@"00" forState:UIControlStateNormal];
//    [button setTitle:@"titletitle1234567890titletitle" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [button setImagePoisition:ImagePoisitionTop];
    _button = button;
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
            [self.bannerList enumerateObjectsUsingBlock:^(ADModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [imageStringArray addObject:obj.imageUrl];
            }];
            
            [self.bannerScrollView setImageArray:imageStringArray];
        }
    }];
}

- (void)homeRightItemClick {
    [_button setImagePoisition:ImagePoisitionTop];
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


