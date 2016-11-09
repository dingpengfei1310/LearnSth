//
//  LoginViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/31.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"

#import "TPKeyboardAvoidingScrollView.h"
#import "UserModel.h"
#import "NSString+Tool.h"

@interface LoginViewController ()

@property (nonatomic, strong) UITextField *accountField;
@property (nonatomic, strong) UITextField *passwordField;

@end

const CGFloat fieldMargin = 30;
const CGFloat fieldHeight = 30;

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self createSubViews];
    
    
    
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createSubViews {
    CGRect scrollRect = CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64);
    TPKeyboardAvoidingScrollView *scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:scrollRect];
    [self.view addSubview:scrollView];
    
    UITextField *accountField = [[UITextField alloc] init];
    accountField.borderStyle = UITextBorderStyleRoundedRect;
    accountField.frame = CGRectMake(fieldMargin, 60, ScreenWidth - fieldMargin * 2, fieldHeight);
    accountField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _accountField = accountField;
    
    CGFloat pwdFieldY = CGRectGetMaxY(accountField.frame) + fieldMargin;
    CGFloat pwdFieldW = ScreenWidth - fieldMargin * 2;
    CGRect pwdFieldRect = CGRectMake(fieldMargin, pwdFieldY, pwdFieldW, fieldHeight);
    UITextField *pwdField = [[UITextField alloc] initWithFrame:pwdFieldRect];
    pwdField.borderStyle = UITextBorderStyleRoundedRect;
    pwdField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passwordField = pwdField;
    
    [scrollView addSubview:_accountField];
    [scrollView addSubview:_passwordField];
    
    CGRect buttonRect = CGRectMake(0, CGRectGetHeight(scrollView.frame) - 40, ScreenWidth, 40);
    UIButton *loginButton = [[UIButton alloc] initWithFrame:buttonRect];
    [loginButton setBackgroundColor:[UIColor redColor]];
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:loginButton];
    
//    CGRect buttonRect1 = CGRectMake(0, CGRectGetHeight(scrollView.frame) - 40 - 40, ScreenWidth, 40);
//    UIButton *regButton = [[UIButton alloc] initWithFrame:buttonRect1];
//    [regButton setBackgroundColor:[UIColor redColor]];
//    [regButton setTitle:@"注册" forState:UIControlStateNormal];
//    [regButton addTarget:self action:@selector(regClick) forControlEvents:UIControlEventTouchUpInside];
//    [scrollView addSubview:regButton];
}

- (void)loginClick {
    if ([_accountField.text validatePhoneNumber]) {
        [[UserModel user] setMobile:self.accountField.text];
        [Utils setIsLogin:YES];
        [self dismiss];
    } else {
        [self showError:@"手机号不正确"];
    }
}

- (void)regClick {
    RegisterViewController *controller = [[RegisterViewController alloc] init];
    [self presentViewController:controller animated:YES completion:nil];
//    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
