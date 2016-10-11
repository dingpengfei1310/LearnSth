//
//  TabBarViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/27.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "TabBarViewController.h"

#import "HomeViewController.h"
#import "LiveViewController.h"
#import "UserViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HomeViewController *homeController = [[HomeViewController alloc] init];
    UINavigationController *homeNVC = [[UINavigationController alloc] initWithRootViewController:homeController];
    
    LiveViewController *liveController = [[LiveViewController alloc] init];
    UINavigationController *liveNVC = [[UINavigationController alloc] initWithRootViewController:liveController];
    
    UserViewController *userController = [[UserViewController alloc] init];
    UINavigationController *userNVC = [[UINavigationController alloc] initWithRootViewController:userController];
    
    self.viewControllers = @[homeNVC,liveNVC,userNVC];
    
    UITabBarItem *item1 = self.tabBar.items[0];
    item1.title = @"home";
    
    UITabBarItem *item2 = self.tabBar.items[1];
    item2.title = @"live";
    
    UITabBarItem *item3 = self.tabBar.items[2];
    item3.title = @"user";
    
    [self setSelectedIndex:2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
