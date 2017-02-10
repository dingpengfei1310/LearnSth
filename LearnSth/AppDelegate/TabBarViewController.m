//
//  TabBarViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/27.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "TabBarViewController.h"
#import "HomeViewController.h"
#import "UserViewController.h"

#import "VideoCaptureController.h"
#import "FilterMovieController.h"

#import "CustomizeButton.h"

@interface TabBarViewController ()

@property (nonatomic, strong) UIView *barView;

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HomeViewController *homeController = [[HomeViewController alloc] init];
    UINavigationController *homeNVC = [[UINavigationController alloc] initWithRootViewController:homeController];
    
    UserViewController *userController = [[UserViewController alloc] init];
    UINavigationController *userNVC = [[UINavigationController alloc] initWithRootViewController:userController];
    
    self.viewControllers = @[homeNVC,userNVC];
    
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
    
    [self customizeBarButton];
}

- (void)customizeBarButton {
    //背景透明、消除黑线
    UIImage *clearImage = [UIImage imageWithColor:[UIColor clearColor]];
    [self.tabBar setBackgroundImage:clearImage];
    [self.tabBar setShadowImage:clearImage];
    
    CGFloat totalWidth = [UIScreen mainScreen].bounds.size.width;
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, totalWidth, 49)];
    barView.backgroundColor = [UIColor whiteColor];
    [self.tabBar addSubview:barView];
    self.barView = barView;
    
    NSArray *titles = @[@"Home",@"",@"User"];
    NSArray *images = @[@"star",@"",@"defaultHeader"];
    CGFloat buttonWidth = totalWidth / titles.count;
    
    for (int i = 0; i < titles.count; i++) {
        
        CGRect buttonRect = CGRectMake(buttonWidth * i, 0, buttonWidth, 49);
        CustomizeButton *button = [[CustomizeButton alloc] initWithFrame:buttonRect];
        if (i == 1) {
            button.frame = CGRectMake(0, 0, 100, 100);
            button.center = CGPointMake(totalWidth * 0.5, 30);
        } else if (i == 0) {
            button.selected = YES;
        }
        button.tag = i;
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:KBaseTextColor forState:UIControlStateNormal];
        [button setTitleColor:KBaseBlueColor forState:UIControlStateSelected];
        [button.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [button setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [button setImagePoisition:ImagePoisitionTop];
        [barView addSubview:button];
    }
}

- (void)buttonClick:(UIButton *)button {
    if (button.selected) {
        return;
    }
    
    [self.barView.subviews enumerateObjectsUsingBlock:^(__kindof UIButton * obj, NSUInteger idx, BOOL * stop) {
        obj.selected = NO;
    }];
    if (button.tag == self.viewControllers.count / 2) {
        [self showActionSheetOnVideoController];
    } else {
        self.selectedIndex = (button.tag < self.viewControllers.count / 2) ? button.tag : button.tag - 1;
    }
    
    button.selected = YES;
}

#pragma mark
- (void)showActionSheetOnVideoController {
    UIAlertController *actionSheet;
    actionSheet = [UIAlertController alertControllerWithTitle:@"视频拍摄"
                                                      message:nil
                                               preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertAction *videoAction = [UIAlertAction actionWithTitle:@"普通拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        VideoCaptureController *controller = [[VideoCaptureController alloc] init];
        [self presentViewController:controller animated:YES completion:nil];
    }];
    
    UIAlertAction *GPUVideoAction = [UIAlertAction actionWithTitle:@"滤镜效果" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        FilterMovieController *controller = [[FilterMovieController alloc] init];
        controller.FilterMovieDismissBlock = ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        [self presentViewController:controller animated:YES completion:nil];
    }];
    
    [actionSheet addAction:cancelAction];
    [actionSheet addAction:videoAction];
    [actionSheet addAction:GPUVideoAction];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
