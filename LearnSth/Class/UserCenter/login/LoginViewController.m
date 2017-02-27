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
#import "UserManager.h"
#import "NSString+Tool.h"

@interface LoginViewController ()

@property (nonatomic, strong) UITextField *accountField;
@property (nonatomic, strong) UITextField *passwordField;

@property (nonatomic, strong) UIButton *loginButton;

@end

const CGFloat topSpace = 60;
const CGFloat fieldMargin = 40;
const CGFloat fieldHeight = 35;

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登录";
    
    CGRect scrollRect = CGRectMake(0, ViewFrame_X, Screen_W, Screen_H);
    TPKeyboardAvoidingScrollView *scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:scrollRect];
//    scrollView.delaysContentTouches = NO;
    [self.view addSubview:scrollView];
    
    [scrollView addSubview:self.accountField];
    [scrollView addSubview:self.passwordField];
    [scrollView addSubview:self.loginButton];
    [self addRegButtonWithView:scrollView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:DDNSLocalizedGetString(@"Close") style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];;
}

- (void)addRegButtonWithView:(TPKeyboardAvoidingScrollView *)scrollView {
    CGFloat buttonW = 80;
    UIFont *font = [UIFont systemFontOfSize:15];
    
    CGFloat regButtonY = topSpace + fieldHeight * 3 + fieldMargin * 1.5;
    CGRect rect = CGRectMake(fieldMargin, regButtonY, buttonW, 40);
    UIButton *regButton = [[UIButton alloc] initWithFrame:rect];
    regButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [regButton.titleLabel setFont:font];
    [regButton setTitle:@"快速注册" forState:UIControlStateNormal];
    [regButton setTitleColor:KBaseTextColor forState:UIControlStateNormal];
    [regButton addTarget:self action:@selector(registerClick) forControlEvents:UIControlEventTouchUpInside];
    
    rect = CGRectMake(Screen_W - buttonW - fieldMargin, regButtonY, buttonW, 40);
    UIButton *forgetButton = [[UIButton alloc] initWithFrame:rect];
    forgetButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [forgetButton.titleLabel setFont:font];
    [forgetButton setTitle:@"忘记密码" forState:UIControlStateNormal];
    [forgetButton setTitleColor:KBaseTextColor forState:UIControlStateNormal];
    [forgetButton addTarget:self action:@selector(forgetClick) forControlEvents:UIControlEventTouchUpInside];
    
    [scrollView addSubview:regButton];
    [scrollView addSubview:forgetButton];
}

#pragma mark
- (void)dismiss {
    if (self.DismissBlock) {
        self.DismissBlock();
    }
}

- (void)loginClick {
    if ([self.accountField.text validatePhoneNumber]) {
        [UserManager manager].mobile = self.accountField.text;
        [UserManager updateUser];
        [Utils setIsLogin:YES];
        
        [self dismiss];
    } else {
        [self showError:@"手机号不正确"];
    }
}

- (void)registerClick {
    RegisterViewController *controller = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)forgetClick {
    
}

#pragma mark
- (void)textFieldValueChange:(UITextField *)textField {
    if (textField == self.accountField) {
        if (textField.text.length > 11) {
            textField.text = [textField.text substringToIndex:11];
        }
    } else if (textField == self.passwordField) {
        if (textField.text.length > 12) {
            textField.text = [textField.text substringToIndex:12];
        }
    }
    
    self.loginButton.enabled = (self.accountField.text.length == 11 && self.passwordField.text.length >= 6);
}

#pragma mark
- (UITextField *)accountField {
    if (!_accountField) {
        CGRect rect = CGRectMake(fieldMargin, topSpace, Screen_W - fieldMargin * 2, fieldHeight);
        
        _accountField = [[UITextField alloc] initWithFrame:rect];
        _accountField.placeholder = @"请输入用户名";
        _accountField.borderStyle = UITextBorderStyleRoundedRect;
        _accountField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _accountField.keyboardType = UIKeyboardTypeNumberPad;
        [_accountField addTarget:self action:@selector(textFieldValueChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _accountField;
}

- (UITextField *)passwordField {
    if (!_passwordField) {
        CGFloat pwdFieldY = topSpace + fieldHeight + fieldMargin / 2;
        CGRect rect = CGRectMake(fieldMargin, pwdFieldY, Screen_W - fieldMargin * 2, fieldHeight);
        
        _passwordField = [[UITextField alloc] initWithFrame:rect];
        _passwordField.placeholder = @"请输入密码";
        _passwordField.borderStyle = UITextBorderStyleRoundedRect;
        _passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passwordField.keyboardType = UIKeyboardTypeASCIICapable;
        _passwordField.secureTextEntry = YES;
        [_passwordField addTarget:self action:@selector(textFieldValueChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _passwordField;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        CGFloat loginButtonY = topSpace + fieldHeight * 2 + fieldMargin * 1.5;
        CGRect rect = CGRectMake(fieldMargin, loginButtonY, Screen_W - fieldMargin * 2, fieldHeight);
        
        _loginButton = [[UIButton alloc] initWithFrame:rect];
        _loginButton.enabled = NO;
        UIImage *image = [UIImage imageWithColor:KBaseBlueColor];
        [_loginButton setBackgroundImage:image
                                forState:UIControlStateNormal];
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginButton addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _loginButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

