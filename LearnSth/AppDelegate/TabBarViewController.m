//
//  TabBarViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/27.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "TabBarViewController.h"

#import "ViewController.h"
#import "ImageViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ViewController *controller = [[ViewController alloc] init];
    UINavigationController *nController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    ImageViewController *imageController = [[ImageViewController alloc] init];
    UINavigationController *imageN = [[UINavigationController alloc] initWithRootViewController:imageController];
    
    self.viewControllers = @[nController,imageN];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
