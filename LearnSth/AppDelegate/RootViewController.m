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

#import "PhotosCollectionController.h"
#import "VideoCameraController.h"
#import "VideoCameraFilterController.h"

#import "CustomizeButton.h"
#import <Photos/Photos.h>

@interface RootViewController ()

@property (nonatomic, strong) UIView *barView;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadViewControllersWithSelectIndex:0];
    
//    NSDictionary *textAttributeNormal = @{
//                                          NSFontAttributeName:[UIFont systemFontOfSize:12],
//                                          NSForegroundColorAttributeName:KBaseTextColor
//                                          };
//    NSDictionary *textAttributeSelect = @{
//                                          NSFontAttributeName:[UIFont systemFontOfSize:12],
//                                          NSForegroundColorAttributeName:KBaseBlueColor
//                                          };
//    NSArray *itemTitles = @[@"Home",@"User"];
//    
//    for (int i = 0; i < self.tabBar.items.count; i++) {
//        UITabBarItem *item = self.tabBar.items[i];
//        [item setTitle:itemTitles[i]];
//        [item setTitleTextAttributes:textAttributeNormal forState:UIControlStateNormal];
//        [item setTitleTextAttributes:textAttributeSelect forState:UIControlStateSelected];
//    }
}

#pragma mark
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
    
    NSString *home = DDLocalizedString(@"首页");
    NSString *user = DDLocalizedString(@"用户");
    
    NSArray *titles = @[home,@"",user];
    NSArray *images = @[@"star",@"",@"defaultHeader"];
    CGFloat buttonWidth = totalWidth / titles.count;
    
    for (int i = 0; i < titles.count; i++) {
        CGRect buttonRect = CGRectMake(buttonWidth * i, 0, buttonWidth, 49);
        CustomizeButton *button = [[CustomizeButton alloc] initWithFrame:buttonRect];
        
        button.tag = i;
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:KBaseTextColor forState:UIControlStateNormal];
        [button setTitleColor:KBaseBlueColor forState:UIControlStateSelected];
        [button.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [button setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == index) {
            [self buttonClick:button];
        }
//        if (i == 1) {
//            button.frame = CGRectMake(0, 0, 100, 100);
//            button.center = CGPointMake(totalWidth * 0.5, 30);
//        }
        
        [button setImagePoisition:ImagePoisitionTop];
        [barView addSubview:button];
    }
}

- (void)buttonClick:(UIButton *)button {
    if (button.tag == self.viewControllers.count / 2) {
        [self showActionSheetOnVideoController];
        return;
    }
    
    if (button.selected) {
        return;
    }
    
    [self.barView.subviews enumerateObjectsUsingBlock:^(__kindof UIButton * obj, NSUInteger idx, BOOL * stop) {
        obj.selected = NO;
    }];
    self.selectedIndex = (button.tag < self.viewControllers.count / 2) ? button.tag : button.tag - 1;
    button.selected = YES;
}

- (void)loadViewControllersWithSelectIndex:(NSInteger)index {
    HomeViewController *homeController = [[HomeViewController alloc] init];
    UINavigationController *homeNVC = [[UINavigationController alloc] initWithRootViewController:homeController];
    
    UserViewController *userController = [[UserViewController alloc] init];
    UINavigationController *userNVC = [[UINavigationController alloc] initWithRootViewController:userController];
    
    self.viewControllers = @[homeNVC,userNVC];
    
    [self customizeBarButtonWithIndex:index];
}

#pragma mark
- (void)showActionSheetOnVideoController {
    UIAlertController *actionSheet;
    actionSheet = [UIAlertController alertControllerWithTitle:@"视频"
                                                      message:nil
                                               preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *videoAction = [UIAlertAction actionWithTitle:@"本地视频"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            [self localVideo];
                                                        }];
    
    UIAlertAction *GPUVideoAction = [UIAlertAction actionWithTitle:@"相机拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if (TARGET_OS_SIMULATOR) {
            [self showError:@"真机使用"];
            return;
        }
        
        VideoCameraFilterController *controller = [[VideoCameraFilterController alloc] init];
        controller.FilterMovieDismissBlock = ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        
//        VideoCameraController *controller = [[VideoCameraController alloc] init];
        
        [self presentViewController:controller animated:YES completion:nil];
    }];
    
    [actionSheet addAction:cancelAction];
    [actionSheet addAction:videoAction];
    [actionSheet addAction:GPUVideoAction];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)localVideo {
    PHFetchResult *collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumVideos options:nil];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection[0] options:nil];
    
    PhotosCollectionController *controller = [[PhotosCollectionController alloc] init];
    controller.title = @"本地视频";
    controller.fetchResult = fetchResult;
    controller.scanType = VideoScanTypeFilter;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:controller];
    
    UIImage *image = [UIImage imageNamed:@"dismiss"];
    controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
