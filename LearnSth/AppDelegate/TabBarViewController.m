//
//  TabBarViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/27.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "TabBarViewController.h"

#import "ViewController.h"
#import "LiveViewController.h"
#import "ImageViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ViewController *controller = [[ViewController alloc] init];
    UINavigationController *NVC = [[UINavigationController alloc] initWithRootViewController:controller];
    
    LiveViewController *liveController = [[LiveViewController alloc] init];
    UINavigationController *liveNVC = [[UINavigationController alloc] initWithRootViewController:liveController];
    
    ImageViewController *imageController = [[ImageViewController alloc] init];
    UINavigationController *imageNVC = [[UINavigationController alloc] initWithRootViewController:imageController];
    
    self.viewControllers = @[NVC,liveNVC,imageNVC];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
