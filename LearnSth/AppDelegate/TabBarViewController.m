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
    
    NSDictionary *textAttributeNormal = @{
                                          NSFontAttributeName:[UIFont systemFontOfSize:12],
                                          NSForegroundColorAttributeName:[UIColor grayColor]
                                          };
    NSDictionary *textAttributeSelect = @{
                                          NSFontAttributeName:[UIFont systemFontOfSize:12],
                                          NSForegroundColorAttributeName:[UIColor redColor]
                                          };
    NSArray *itemTitles = @[@"home",@"live",@"user"];
    
    for (int i = 0; i < itemTitles.count; i++) {
        UITabBarItem *item = self.tabBar.items[i];
        item.title = itemTitles[i];
        [item setTitleTextAttributes:textAttributeNormal forState:UIControlStateNormal];
        [item setTitleTextAttributes:textAttributeSelect forState:UIControlStateSelected];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
