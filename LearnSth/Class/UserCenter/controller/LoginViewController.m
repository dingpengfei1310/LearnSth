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
#import "UIImage+Tool.h"

@interface LoginViewController () {
    CGFloat viewW;
}

@property (nonatomic, strong) UITextField *accountField;
@property (nonatomic, strong) UITextField *passwordField;

@property (nonatomic, strong) UIButton *loginButton;//登录
@property (nonatomic, strong) UIButton *quickRegButton;//快速注册、返回登录
@property (nonatomic, strong) UIButton *forgetButton;//忘记密码

@property (nonatomic, strong) NSDictionary *attNormal;
@property (nonatomic, strong) NSDictionary *attHighlighted;

@property (nonatomic, assign) BOOL isLoginState;//是否是登录模式（还有注册模式）

@end

const CGFloat topSpace = 64;//页面上方空白高度
const CGFloat fieldMargin = 40;//左右边距
const CGFloat fieldHeight = 40;//输入框和登录按钮高度

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登录";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initSubView];
    self.isLoginState = YES;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissLoginController)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)initSubView {
    viewW = CGRectGetWidth(self.view.frame);
    TPKeyboardAvoidingScrollView *scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 64, viewW, Screen_H - 64)];
    [self.view addSubview:scrollView];

    CGFloat filedW = viewW - fieldMargin * 2;
    //账号
    _accountField = [[UITextField alloc] initWithFrame:CGRectMake(fieldMargin, topSpace, filedW, fieldHeight)];
    _accountField.placeholder = @"请输入手机号";
    _accountField.text = [UserManager shareManager].mobile;
    _accountField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _accountField.keyboardType = UIKeyboardTypeNumberPad;
    _accountField.leftViewMode = UITextFieldViewModeAlways;
    [_accountField addTarget:self action:@selector(textFieldValueChange:) forControlEvents:UIControlEventEditingChanged];
    [scrollView addSubview:self.accountField];
    
    UILabel *accountL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fieldHeight * 1.5, fieldHeight)];
    accountL.text = @"账号";
    _accountField.leftView = accountL;
    
    UIView *accountLine = [[UIView alloc] initWithFrame:CGRectMake(fieldMargin, topSpace + fieldHeight, filedW, 1.0)];
    accountLine.backgroundColor = KBackgroundColor;
    [scrollView addSubview:accountLine];
    
    //密码
    CGFloat pwdFieldY = topSpace + fieldHeight;
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(fieldMargin, pwdFieldY, filedW, fieldHeight)];
    _passwordField.placeholder = @"请输入密码";
    _passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passwordField.leftViewMode = UITextFieldViewModeAlways;
    _passwordField.keyboardType = UIKeyboardTypeASCIICapable;
    _passwordField.clearsOnBeginEditing = NO;
    _passwordField.secureTextEntry = YES;
    [_passwordField addTarget:self action:@selector(textFieldValueChange:) forControlEvents:UIControlEventEditingChanged];
    [scrollView addSubview:self.passwordField];
    
    UILabel *pwdL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fieldHeight * 1.5, fieldHeight)];
    pwdL.text = @"密码";
    _passwordField.leftView = pwdL;
    
    UIView *pwdLine = [[UIView alloc] initWithFrame:CGRectMake(fieldMargin, topSpace + fieldHeight * 2, filedW, 1.0)];
    pwdLine.backgroundColor = KBackgroundColor;
    [scrollView addSubview:pwdLine];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(fieldMargin, topSpace + fieldHeight * 2, filedW, 20)];
    tipLabel.text = @"密码为6-12位数字和字母，不能为纯数字";
    tipLabel.textColor = KBaseTextColor;
    tipLabel.font = [UIFont systemFontOfSize:13];
    [scrollView addSubview:tipLabel];
    
    //**************************************************
    //登录按钮
    CGFloat loginButtonY = topSpace + fieldHeight * 2 + fieldMargin + 20;
    _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(fieldMargin, loginButtonY, filedW, fieldHeight * 1.2)];
    _loginButton.enabled = NO;
    UIImage *image = [CustomiseTool imageWithColor:KBaseBlueColor];
    UIImage *cornerImage = [image cornerImageWithSize:CGSizeMake(viewW - fieldMargin * 2, fieldHeight * 1.2) radius:3];
    [_loginButton setBackgroundImage:cornerImage forState:UIControlStateNormal];
    [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.loginButton];
    
    //快速注册
    CGFloat buttonW = 80;
    UIFont *font = [UIFont systemFontOfSize:16];
    _attNormal = @{NSFontAttributeName:font,NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)};
    _attHighlighted = @{NSFontAttributeName:font,
                        NSForegroundColorAttributeName:KBaseTextColor,
                        NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)};
    
    CGFloat quickRegButtonY = CGRectGetMaxY(self.loginButton.frame);
    CGRect rect = CGRectMake(fieldMargin, quickRegButtonY, buttonW, 40);
    _quickRegButton = [[UIButton alloc] initWithFrame:rect];
    _quickRegButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    NSAttributedString *stringNormal = [[NSAttributedString alloc] initWithString:@"快速注册" attributes:_attNormal];
    NSAttributedString *stringHighlighted = [[NSAttributedString alloc] initWithString:@"快速注册" attributes:_attHighlighted];
    [_quickRegButton setAttributedTitle:stringNormal forState:UIControlStateNormal];
    [_quickRegButton setAttributedTitle:stringHighlighted forState:UIControlStateHighlighted];
    [_quickRegButton addTarget:self action:@selector(quickRegisterClick:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.quickRegButton];
    
    //忘记密码
    rect = CGRectMake(viewW - buttonW - fieldMargin, quickRegButtonY, buttonW, 40);
    _forgetButton = [[UIButton alloc] initWithFrame:rect];
    _forgetButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    stringNormal = [[NSAttributedString alloc] initWithString:@"忘记密码?" attributes:_attNormal];
    stringHighlighted = [[NSAttributedString alloc] initWithString:@"忘记密码?" attributes:_attHighlighted];
    [_forgetButton setAttributedTitle:stringNormal forState:UIControlStateNormal];
    [_forgetButton setAttributedTitle:stringHighlighted forState:UIControlStateHighlighted];
    [_forgetButton addTarget:self action:@selector(forgetClick) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.forgetButton];
}

#pragma mark
- (void)dismissLoginController {
    if (self.LoginDismissBlock) {
        self.LoginDismissBlock();
    }
}

- (void)loginClick {
    if (self.isLoginState) {
        [self loginAction];
        
    } else {
        [self registerAction];
    }
}

- (void)quickRegisterClick:(UIButton *)button {
    RegisterViewController *controller = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    
//    self.isLoginState = !self.isLoginState;
//    if (self.isLoginState) {
//        self.title = @"登录";
//        self.forgetButton.hidden = NO;
//        [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
//        
//        [button setAttributedTitle:[[NSAttributedString alloc] initWithString:@"快速注册" attributes:_attNormal]
//                          forState:UIControlStateNormal];
//        [button setAttributedTitle:[[NSAttributedString alloc] initWithString:@"快速注册" attributes:_attHighlighted]
//                          forState:UIControlStateHighlighted];
//        
//        self.accountField.text = [UserManager shareManager].mobile;
//        
//    } else {
//        self.title = @"注册";
//        self.forgetButton.hidden = YES;
//        [self.loginButton setTitle:@"注册" forState:UIControlStateNormal];
//        
//        [button setAttributedTitle:[[NSAttributedString alloc] initWithString:@"返回登录" attributes:_attNormal]
//                          forState:UIControlStateNormal];
//        [button setAttributedTitle:[[NSAttributedString alloc] initWithString:@"返回登录" attributes:_attHighlighted]
//                          forState:UIControlStateHighlighted];
//        self.accountField.text = nil;
//    }
//    
//    self.passwordField.text = nil;
//    self.loginButton.enabled = NO;
}

- (void)forgetClick {
    [self showAlertWithTitle:nil message:@"怪我咯😂" operationTitle:@"知道了" operation:nil];
}

- (void)loginAction {
    if ([self validateAccountAndPwd]) {
        NSString *password = [self.passwordField.text MD5String];
        UserManager *manager = [UserManager shareManager];
        
        if ([manager.mobile isEqualToString:self.accountField.text] && [manager.password isEqualToString:password]) {
            
            [self loadingWithText:@"登录中..."];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self hideHUD];
                [self performSelector:@selector(dismissLoginController) withObject:nil afterDelay:0.1];
                
                [CustomiseTool setIsLogin:YES];
            });
            
        } else {
            [self showError:@"手机号或密码不正确"];
        }
    }
}

- (void)registerAction {
    if ([self validateAccountAndPwd]) {
        [self loadingWithText:@"注册中..."];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [self hideHUD];
            [self dismissLoginController];
            
            NSString *password = [self.passwordField.text MD5String];
            [UserManager shareManager].mobile = self.accountField.text;
            [UserManager shareManager].password = password;
            [UserManager shareManager].username = @"我是谁";
            
            UIImage *image = [UIImage imageNamed:@"defaultHeader"];
            [UserManager shareManager].headerImageData = UIImagePNGRepresentation(image);
            [UserManager updateUser];
            
            [CustomiseTool setIsLogin:YES];
            
        });
    }
}

- (BOOL)validateAccountAndPwd {
    if (![self.accountField.text validatePhoneNumber]) {
        [self showError:@"手机号格式不正确"];
        return NO;
    }
    
    if (![self.passwordField.text validatePassword]) {
        [self showError:@"密码格式不正确"];
        return NO;
    }
    
    [self.view endEditing:YES];
    return YES;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
