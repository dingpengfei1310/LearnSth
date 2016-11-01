//
//  LoginViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/31.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "LoginViewController.h"

#import "TPKeyboardAvoidingScrollView.h"

@interface LoginViewController ()

@end

const CGFloat fieldMargin = 30;
const CGFloat fieldHeight = 30;

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    
    [self createSubViews];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createSubViews {
    TPKeyboardAvoidingScrollView *scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
    [self.view addSubview:scrollView];
    
    UITextField *accountField = [[UITextField alloc] init];
    accountField.borderStyle = UITextBorderStyleRoundedRect;
    accountField.frame = CGRectMake(fieldMargin, 60, ScreenWidth - fieldMargin * 2, fieldHeight);
    accountField.clearButtonMode = UITextFieldViewModeWhileEditing;
    accountField.leftViewMode = UITextFieldViewModeAlways;
    
    UITextField *pwdField = [[UITextField alloc] init];
    pwdField.borderStyle = UITextBorderStyleRoundedRect;
    pwdField.frame = CGRectMake(fieldMargin, CGRectGetMaxY(accountField.frame) + fieldMargin, ScreenWidth - fieldMargin * 2, fieldHeight);
    pwdField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [scrollView addSubview:accountField];
    [scrollView addSubview:pwdField];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(scrollView.frame) - 40, ScreenWidth, 40)];
    [button setBackgroundColor:[UIColor redColor]];
    [button setTitle:@"登录" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:button];
}

- (void)loginClick {
    [Utils setIsLogin:YES];
    [self dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
