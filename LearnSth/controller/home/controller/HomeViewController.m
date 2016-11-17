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
#import "UIImage+Tool.h"

@interface HomeViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"00" style:UIBarButtonItemStylePlain target:self action:@selector(popoverController)];
    
//    AnimationView *aView = [[AnimationView alloc] initWithFrame:CGRectMake(50, 124, 200, 200)];
//    [self.view addSubview:aView];
    
}

- (void)popoverController {
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
