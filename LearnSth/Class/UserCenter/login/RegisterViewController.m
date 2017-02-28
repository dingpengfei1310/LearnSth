//
//  RegisterViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/8.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "RegisterViewController.h"
#import "BaseControllerProtocol.h"

@interface RegisterViewController ()

@property (nonatomic, strong) UIButton *registerButton;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注册";
    
    [self.view addSubview:self.registerButton];
}

- (void)regClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark
- (UIButton *)registerButton {
    if (!_registerButton) {
        _registerButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 200, Screen_W - 80, 40)];
//        _registerButton.enabled = NO;
        UIImage *image = [UIImage imageWithColor:KBaseBlueColor];
        [_registerButton setBackgroundImage:image
                                forState:UIControlStateNormal];
        [_registerButton setTitle:@"注册" forState:UIControlStateNormal];
        [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_registerButton addTarget:self action:@selector(regClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _registerButton;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

