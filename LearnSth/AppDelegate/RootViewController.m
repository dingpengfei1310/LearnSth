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

#import "CustomizeButton.h"
#import <AFNetworkReachabilityManager.h>

#if !TARGET_OS_SIMULATOR
#import "VideoCameraController.h"
#import "VideoCameraFilterController.h"
#endif

@interface RootViewController ()
@property (nonatomic, strong) UIView *barView;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self networkMonitoring];
    [self loadViewControllersWithSelectIndex:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeModel) name:ChangeNightModel object:nil];
    
    [self changeModel];
}

#pragma mark
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

- (void)checkNetworkType {
    UIApplication *application = [UIApplication sharedApplication];
    NSArray *children;
    if ([[application valueForKeyPath:@"_statusBar"] isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
        children = [[[[application valueForKeyPath:@"_statusBar"] valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    } else {
        children = [[[application valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    }
    
    NSString *status = [[NSString alloc] init];
    NSInteger netType = 0;
    
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            netType = [[child valueForKeyPath:@"dataNetworkType"] integerValue];
            
            switch (netType) {
                case 0:
                    status = @"noNet";
                    break;
                case 1:
                    status = @"2G";
                    break;
                case 2:
                    status = @"3G";
                    break;
                case 3:
                    status = @"4G";
                    break;
                case 5:
                    status = @"WIFI";
                    break;
                default:
                    break;
            }
        }
    }
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
    if ([CustomiseTool isNightModel]) {
        barView.backgroundColor = [UIColor darkGrayColor];
    } else {
        barView.backgroundColor = [UIColor whiteColor];
    }
    
    NSArray *titles = @[@"00",@"",@"22"];//必须为奇数，也就是真实的controller必须是偶数个
    CGFloat buttonWidth = totalWidth / titles.count;
    
    for (int i = 0; i < titles.count; i++) {
        CGRect buttonRect = CGRectMake(buttonWidth * i, 0, buttonWidth, 49);
        CustomizeButton *button = [[CustomizeButton alloc] initWithFrame:buttonRect];
        button.tag = i;
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:KBaseTextColor forState:UIControlStateNormal];
        [button setTitleColor:KBaseAppColor forState:UIControlStateSelected];
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
                                          NSForegroundColorAttributeName:KBaseAppColor};
    
    NSArray *itemTitles = @[@"00",@"22"];
    for (int i = 0; i < self.tabBar.items.count; i++) {
        UITabBarItem *item = self.tabBar.items[i];
        [item setTitle:itemTitles[i]];
        [item setTitleTextAttributes:textAttributeNormal forState:UIControlStateNormal];
        [item setTitleTextAttributes:textAttributeSelect forState:UIControlStateSelected];
    }
}

- (void)changeModel {
    if ([CustomiseTool isNightModel]) {
        self.barView.backgroundColor = [UIColor darkGrayColor];
        
        UIView *modelView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        modelView.tag = 1111;
        modelView.userInteractionEnabled = NO;
        modelView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
        [[UIApplication sharedApplication].keyWindow addSubview:modelView];
        
    } else {
        self.barView.backgroundColor = [UIColor whiteColor];
        
        for (UIView *subView in [UIApplication sharedApplication].keyWindow.subviews) {
            if (subView.tag == 1111) {
                [subView removeFromSuperview];
            }
        }
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
    
#if !TARGET_OS_SIMULATOR
    UIAlertAction *GPUVideoAction = [UIAlertAction actionWithTitle:@"相机拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//        VideoCameraController *controller = [[VideoCameraController alloc] init];
        VideoCameraFilterController *controller = [[VideoCameraFilterController alloc] init];
        controller.FilterMovieDismissBlock = ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        [self presentViewController:controller animated:YES completion:nil];
    }];
    [actionSheet addAction:GPUVideoAction];
#endif
    
    [actionSheet addAction:cancelAction];
    [actionSheet addAction:videoAction];
    
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
