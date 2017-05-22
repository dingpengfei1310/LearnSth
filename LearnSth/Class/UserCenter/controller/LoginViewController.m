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

@interface LoginViewController () {
    CGFloat viewW;
}

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissLoginController)];
    
    [self initSubView];
}

- (void)initSubView {
    viewW = self.view.frame.size.width;
    TPKeyboardAvoidingScrollView *scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 64, viewW, self.view.frame.size.height - 64)];
    [self.view addSubview:scrollView];
    
    //输入框
    [scrollView addSubview:self.accountField];
    [scrollView addSubview:self.passwordField];
    [scrollView addSubview:self.loginButton];
    
    //按钮
    CGFloat buttonW = 80;
    UIFont *font = [UIFont systemFontOfSize:15];
    NSDictionary *attNormal = @{NSFontAttributeName:font,NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)};
    NSDictionary *attHighlighted = @{NSFontAttributeName:font,
                                     NSForegroundColorAttributeName:KBaseTextColor,
                                     NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)};
    
    CGFloat regButtonY = CGRectGetMaxY(self.loginButton.frame);
    CGRect rect = CGRectMake(fieldMargin, regButtonY, buttonW, 40);
    UIButton *regButton = [[UIButton alloc] initWithFrame:rect];
    regButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    NSAttributedString *attStringNormal = [[NSAttributedString alloc] initWithString:@"快速注册" attributes:attNormal];
    NSAttributedString *attStringHigh = [[NSAttributedString alloc] initWithString:@"快速注册" attributes:attHighlighted];
    [regButton setAttributedTitle:attStringNormal forState:UIControlStateNormal];
    [regButton setAttributedTitle:attStringHigh forState:UIControlStateHighlighted];
    [regButton addTarget:self action:@selector(registerClick) forControlEvents:UIControlEventTouchUpInside];
    
    rect = CGRectMake(viewW - buttonW - fieldMargin, regButtonY, buttonW, 40);
    UIButton *forgetButton = [[UIButton alloc] initWithFrame:rect];
    forgetButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    attStringNormal = [[NSAttributedString alloc] initWithString:@"忘记密码?" attributes:attNormal];
    attStringHigh = [[NSAttributedString alloc] initWithString:@"忘记密码?" attributes:attHighlighted];
    [forgetButton setAttributedTitle:attStringNormal forState:UIControlStateNormal];
    [forgetButton setAttributedTitle:attStringHigh forState:UIControlStateHighlighted];
    [forgetButton addTarget:self action:@selector(forgetClick) forControlEvents:UIControlEventTouchUpInside];
    
    [scrollView addSubview:regButton];
    [scrollView addSubview:forgetButton];
}

#pragma mark
- (void)dismissLoginController {
    if (self.LoginDismissBlock) {
        self.LoginDismissBlock();
    }
}

- (void)loginClick {
    if ([self.accountField.text validatePhoneNumber]) {
        if (![[UserManager shareManager].mobile isEqualToString:self.accountField.text]) {
            [UserManager shareManager].mobile = self.accountField.text;
            [UserManager shareManager].username = @"用户007";
            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"catDance.gif" ofType:nil];
            [UserManager shareManager].headerImageData = [NSData dataWithContentsOfFile:path];
            
            [UserManager updateUser];
        }
        
        [CustomiseTool setIsLogin:YES];
        [self dismissLoginController];
        
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
        CGRect rect = CGRectMake(fieldMargin, topSpace, viewW - fieldMargin * 2, fieldHeight);
        
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
        CGRect rect = CGRectMake(fieldMargin, pwdFieldY, viewW - fieldMargin * 2, fieldHeight);
        
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
        CGRect rect = CGRectMake(fieldMargin, loginButtonY, viewW - fieldMargin * 2, fieldHeight * 1.2);
        
        _loginButton = [[UIButton alloc] initWithFrame:rect];
        _loginButton.enabled = NO;
        UIImage *image = [CustomiseTool imageWithColor:KBaseBlueColor];
        [_loginButton setBackgroundImage:image forState:UIControlStateNormal];
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
