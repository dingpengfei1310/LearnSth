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

@interface LoginViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *accountField;
@property (nonatomic, strong) UITextField *passwordField;

@property (nonatomic, strong) UIButton *loginButton;

@end

const CGFloat fieldMargin = 40;
const CGFloat fieldHeight = 40;

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登录";
    
    CGRect scrollRect = CGRectMake(0, ViewFrameOrigin_X, ScreenWidth, ScreenHeight - 64);
    TPKeyboardAvoidingScrollView *scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:scrollRect];
    [self.view addSubview:scrollView];
    
    [scrollView addSubview:self.accountField];
    [scrollView addSubview:self.passwordField];
    [scrollView addSubview:self.loginButton];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGFloat textFieldW = ScreenWidth - fieldMargin * 2;
    self.accountField.frame = CGRectMake(fieldMargin, 60, textFieldW, fieldHeight);
    
    CGFloat pwdFieldY = CGRectGetMaxY(self.accountField.frame) + fieldMargin / 2;
    self.passwordField.frame = CGRectMake(fieldMargin, pwdFieldY, textFieldW, fieldHeight);
    
    CGFloat loginButtonY = CGRectGetMaxY(self.passwordField.frame) + fieldMargin;
    self.loginButton.frame = CGRectMake(fieldMargin, loginButtonY, textFieldW, fieldHeight);
}

#pragma mark

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginClick {
    if ([_accountField.text validatePhoneNumber]) {
        [[UserModel userManager] setMobile:self.accountField.text];
        [Utils setIsLogin:YES];
        [self dismiss];
    } else {
        [self showError:@"手机号不正确"];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.accountField) {
        if (range.location > 10) {
            return NO;
        }
    }
    return YES;
}

#pragma mark
- (UITextField *)accountField {
    if (!_accountField) {
        _accountField = [[UITextField alloc] init];
        _accountField.placeholder = @"请输入用户名";
        _accountField.delegate = self;
        _accountField.borderStyle = UITextBorderStyleRoundedRect;
        _accountField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _accountField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _accountField;
}

- (UITextField *)passwordField {
    if (!_passwordField) {
        _passwordField = [[UITextField alloc] init];
        _passwordField.placeholder = @"请输入密码";
        _passwordField.borderStyle = UITextBorderStyleRoundedRect;
        _passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passwordField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _passwordField;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [[UIButton alloc] init];
        [_loginButton setBackgroundColor:KBaseBlueColor];
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [_loginButton addTarget:self
                         action:@selector(loginClick)
               forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _loginButton;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
