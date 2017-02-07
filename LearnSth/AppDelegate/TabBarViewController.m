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

#import "CustomizeButton.h"

@interface TabBarViewController ()

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
//    NSArray *itemTitles = @[@"Home",@"",@"User"];
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
    
    NSArray *titles = @[@"Home",@"",@"User"];
    NSArray *images = @[@"defaultHeader",@"reflesh1",@"defaultHeader"];
    CGFloat buttonWidth = totalWidth / titles.count;
    
    for (int i = 0; i < titles.count; i++) {
        
        CGRect buttonRect = CGRectMake(buttonWidth * i, 0, buttonWidth, 49);
        CustomizeButton *button = [[CustomizeButton alloc] initWithFrame:buttonRect];
        if (i == 1) {
            button.frame = CGRectMake(0, 0, 60, 60);
            button.center = CGPointMake(totalWidth * 0.5, 30);
        }
        button.tag = i;
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
        
        [button setTitleColor:KBaseTextColor forState:UIControlStateNormal];
        [button setTitleColor:KBaseBlueColor forState:UIControlStateSelected];
        
        [button setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [button setImagePoisition:ImagePoisitionTop];
        [barView addSubview:button];
    }
}

- (void)buttonClick:(UIButton *)button {
    if (button.tag < self.viewControllers.count / 2) {
        self.selectedIndex = button.tag;
        
    } else if (button.tag > self.viewControllers.count / 2) {
        self.selectedIndex = button.tag - 1;
        
    } else {
        [self showError:@"正在开发中"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
