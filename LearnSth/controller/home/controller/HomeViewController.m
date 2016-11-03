//
//  ViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "HomeViewController.h"
#import "WebViewController.h"

#import "AnimationView.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"00" style:UIBarButtonItemStylePlain target:self action:@selector(popoverController)];
    
    AnimationView *aView = [[AnimationView alloc] initWithFrame:CGRectMake(50, 124, 100, 100)];
    [self.view addSubview:aView];
    
}

- (void)popoverController {
    WebViewController *controller = [[WebViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
