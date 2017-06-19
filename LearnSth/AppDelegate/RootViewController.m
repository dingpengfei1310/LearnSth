//
//  TabBarViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/27.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "RootViewController.h"
#import "HomeViewController.h"
#import "UserViewController.h"

#import "PhotoLibraryController.h"
#import "VideoCameraController.h"
#import "VideoCameraFilterController.h"

#import "CustomizeButton.h"
#import <AFNetworkReachabilityManager.h>

@interface RootViewController ()

@property (nonatomic, strong) UIView *barView;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadViewControllersWithSelectIndex:0];
    [self networkMonitoring];
}

- (void)networkMonitoring {
    __block BOOL isFirst = YES;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (!isFirst) {
            if (status == AFNetworkReachabilityStatusNotReachable) {
                [self showError:@"网络已断开连接"];
            } else if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
                [self showSuccess:@"网络已连接"];
            }
        }
        isFirst = NO;
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

#pragma mark
- (void)loadViewControllersWithSelectIndex:(NSInteger)index {
    HomeViewController *homeController = [[HomeViewController alloc] init];
    UINavigationController *homeNVC = [[UINavigationController alloc] initWithRootViewController:homeController];
    
    UserViewController *userController = [[UserViewController alloc] init];
    UINavigationController *userNVC = [[UINavigationController alloc] initWithRootViewController:userController];
    
    self.viewControllers = @[homeNVC,userNVC];
    
    [self customizeBarButtonWithIndex:index];
    //    [self initTabBar];
}

///自定义tabBar
- (void)customizeBarButtonWithIndex:(NSInteger)index {
    //背景透明、消除黑线
    UIImage *clearImage = [CustomiseTool imageWithColor:[UIColor clearColor]];
    [self.tabBar setBackgroundImage:clearImage];
    [self.tabBar setShadowImage:clearImage];
    
    CGFloat totalWidth = [UIScreen mainScreen].bounds.size.width;
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, totalWidth, 49)];
    barView.backgroundColor = [UIColor whiteColor];
    [self.tabBar addSubview:barView];
    self.barView = barView;
    
    NSArray *titles = @[@"00",@"",@"22"];//必须为奇数，也就是真实的controller必须是偶数个
    CGFloat buttonWidth = totalWidth / titles.count;
    
    for (int i = 0; i < titles.count; i++) {
        CGRect buttonRect = CGRectMake(buttonWidth * i, 0, buttonWidth, 49);
        CustomizeButton *button = [[CustomizeButton alloc] initWithFrame:buttonRect];
        button.tag = i;
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:KBaseTextColor forState:UIControlStateNormal];
        [button setTitleColor:KBaseBlueColor forState:UIControlStateSelected];
        [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setImagePoisition:ImagePoisitionTop];
        
        if (i == index) {
            //当前选中的
            [self buttonClick:button];
        } else if (i == titles.count / 2) {
//            //理论上，中间这个不会是选中状态
//            button.frame = CGRectMake(0, 0, 80, 80);
//            button.center = CGPointMake(totalWidth * 0.5, 20);
//            [button setImage:[UIImage imageNamed:@"redSpot"] forState:UIControlStateNormal];
        }
        
        [barView addSubview:button];
    }
}

- (void)buttonClick:(UIButton *)button {
    if (button.tag == self.viewControllers.count / 2) {
        [self showActionSheetOnVideoController];
        
    } else if (!button.selected) {
        [self.barView.subviews enumerateObjectsUsingBlock:^(__kindof UIButton * obj, NSUInteger idx, BOOL * stop) {
            obj.selected = NO;
        }];
        self.selectedIndex = (button.tag < self.viewControllers.count / 2) ? button.tag : button.tag - 1;
        button.selected = YES;
    }
}

///系统样式的tabBar
- (void)initTabBar {
    NSDictionary *textAttributeNormal = @{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                          NSForegroundColorAttributeName:KBaseTextColor};
    NSDictionary *textAttributeSelect = @{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                          NSForegroundColorAttributeName:KBaseBlueColor};
    
    NSArray *itemTitles = @[@"00",@"22"];
    for (int i = 0; i < self.tabBar.items.count; i++) {
        UITabBarItem *item = self.tabBar.items[i];
        [item setTitle:itemTitles[i]];
        [item setTitleTextAttributes:textAttributeNormal forState:UIControlStateNormal];
        [item setTitleTextAttributes:textAttributeSelect forState:UIControlStateSelected];
    }
}

#pragma mark
- (void)showActionSheetOnVideoController {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"视频" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *videoAction = [UIAlertAction actionWithTitle:@"相册视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self localVideo];
    }];
    
    UIAlertAction *GPUVideoAction = [UIAlertAction actionWithTitle:@"相机拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        VideoCameraController *controller = [[VideoCameraController alloc] init];
//        VideoCameraFilterController *controller = [[VideoCameraFilterController alloc] init];
//        controller.FilterMovieDismissBlock = ^{
//            [self dismissViewControllerAnimated:YES completion:nil];
//        };
        [self presentViewController:controller animated:YES completion:nil];
    }];
    
    [actionSheet addAction:cancelAction];
    [actionSheet addAction:videoAction];
    if (!TARGET_OS_SIMULATOR) {
        [actionSheet addAction:GPUVideoAction];
    }
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)localVideo {
    PhotoLibraryController *controller = [[PhotoLibraryController alloc] init];
    controller.subtype = PhotoCollectionSubtypeVideo;
    controller.LibraryDismissBlock = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
