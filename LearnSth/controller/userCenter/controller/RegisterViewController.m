//
//  RegisterViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/8.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    CGRect buttonRect1 = CGRectMake(0, 100, ScreenWidth, 40);
    UIButton *regButton = [[UIButton alloc] initWithFrame:buttonRect1];
    [regButton setBackgroundColor:[UIColor redColor]];
    [regButton setTitle:@"注册" forState:UIControlStateNormal];
    [regButton addTarget:self action:@selector(regClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:regButton];
}

- (void)regClick {
    self.presentingViewController.view.alpha = 0;
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"register" object:nil];
    
//    [self performSelector:@selector(post:) withObject:nil afterDelay:1.0];
}

- (void)post:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"register" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
