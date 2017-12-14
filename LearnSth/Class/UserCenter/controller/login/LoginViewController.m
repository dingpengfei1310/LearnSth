//
//  LoginViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/31.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "LoginViewController.h"
#import "CodeLoginViewController.h"
#import "FindPasswordController.h"

#import "TPKeyboardAvoidingScrollView.h"
#import "UserManager.h"
#import "NSString+Tool.h"
#import "UIImage+Tool.h"
#import "HttpConnection.h"

@interface LoginViewController () {
    CGFloat topSpace;//页面上方空白高度
    CGFloat fieldMargin;//左右边距
    CGFloat fieldHeight;//输入框和登录按钮高度
}

@property (nonatomic, strong) UITextField *accountField;
@property (nonatomic, strong) UITextField *passwordField;

@property (nonatomic, strong) UIButton *loginButton;//登录
@property (nonatomic, strong) UIButton *quickLoginButton;//快速登录
@property (nonatomic, strong) UIButton *forgetButton;//忘记密码

@property (nonatomic, strong) NSDictionary *attNormal;
@property (nonatomic, strong) NSDictionary *attHighlighted;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登录";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initSubView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissLoginController)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(quickRegisterClick:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)initSubView {
    topSpace = 44;
    fieldMargin = 40;
    fieldHeight = 40;
    
    CGFloat barH = NavigationBarH + StatusBarH;
    CGRect frame = CGRectMake(0, barH, Screen_W, Screen_H - barH);
    TPKeyboardAvoidingScrollView *scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:frame];
    [self.view addSubview:scrollView];

    CGFloat filedW = Screen_W - fieldMargin * 2;
    //账号
    _accountField = [[UITextField alloc] initWithFrame:CGRectMake(fieldMargin, topSpace, filedW, fieldHeight)];
    _accountField.placeholder = @"请输入手机号";
    _accountField.text = [UserManager shareManager].mobilePhoneNumber;
    _accountField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _accountField.keyboardType = UIKeyboardTypeNumberPad;
    _accountField.leftViewMode = UITextFieldViewModeAlways;
    [_accountField addTarget:self action:@selector(textFieldValueChange:) forControlEvents:UIControlEventEditingChanged];
    [scrollView addSubview:self.accountField];
    
    UILabel *accountL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fieldHeight * 1.2, fieldHeight)];
    accountL.text = @"账号";
    _accountField.leftView = accountL;
    
    UIView *accountLine = [[UIView alloc] initWithFrame:CGRectMake(fieldMargin, CGRectGetMaxY(_accountField.frame), filedW, 1.0)];
    accountLine.backgroundColor = KBackgroundColor;
    [scrollView addSubview:accountLine];
    
    //密码
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(fieldMargin, CGRectGetMaxY(_accountField.frame), filedW, fieldHeight)];
    _passwordField.placeholder = @"请输入密码";
    _passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passwordField.leftViewMode = UITextFieldViewModeAlways;
    _passwordField.keyboardType = UIKeyboardTypeASCIICapable;
    _passwordField.clearsOnBeginEditing = NO;
    _passwordField.secureTextEntry = YES;
    [_passwordField addTarget:self action:@selector(textFieldValueChange:) forControlEvents:UIControlEventEditingChanged];
    [scrollView addSubview:self.passwordField];
    
    UILabel *pwdL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fieldHeight * 1.2, fieldHeight)];
    pwdL.text = @"密码";
    _passwordField.leftView = pwdL;
    
    UIView *pwdLine = [[UIView alloc] initWithFrame:CGRectMake(fieldMargin, CGRectGetMaxY(_passwordField.frame), filedW, 1.0)];
    pwdLine.backgroundColor = KBackgroundColor;
    [scrollView addSubview:pwdLine];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(fieldMargin, CGRectGetMaxY(_passwordField.frame), filedW, 20)];
    tipLabel.text = @"密码为6-12位数字和字母,不能为纯数字";
    tipLabel.textColor = KBaseTextColor;
    tipLabel.font = [UIFont systemFontOfSize:13];
    [scrollView addSubview:tipLabel];
    
    //**************************************************
    //登录按钮
    CGFloat loginButtonY = CGRectGetMaxY(_passwordField.frame)+ fieldMargin;
    _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(fieldMargin, loginButtonY, filedW, fieldHeight * 1.2)];
    _loginButton.enabled = NO;
    UIImage *image = [UIImage imageWithColor:KBaseAppColor];
    UIImage *cornerImage = [image cornerImageWithSize:_loginButton.frame.size radius:3];
    [_loginButton setBackgroundImage:cornerImage forState:UIControlStateNormal];
    [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.loginButton];
    
    //快速登录
    CGFloat buttonW = 80;
    UIFont *font = [UIFont systemFontOfSize:16];
    _attNormal = @{NSFontAttributeName:font,NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)};
    _attHighlighted = @{NSFontAttributeName:font,
                        NSForegroundColorAttributeName:KBaseTextColor,
                        NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)};
    
    CGFloat quickRegButtonY = CGRectGetMaxY(self.loginButton.frame);
    CGRect rect = CGRectMake(fieldMargin, quickRegButtonY, buttonW, 40);
    _quickLoginButton = [[UIButton alloc] initWithFrame:rect];
    _quickLoginButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    NSAttributedString *stringNormal = [[NSAttributedString alloc] initWithString:@"快速登录" attributes:_attNormal];
    NSAttributedString *stringHighlighted = [[NSAttributedString alloc] initWithString:@"快速登录" attributes:_attHighlighted];
    [_quickLoginButton setAttributedTitle:stringNormal forState:UIControlStateNormal];
    [_quickLoginButton setAttributedTitle:stringHighlighted forState:UIControlStateHighlighted];
    [_quickLoginButton addTarget:self action:@selector(quickRegisterClick:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.quickLoginButton];
    
    //忘记密码
    rect = CGRectMake(Screen_W - buttonW - fieldMargin, quickRegButtonY, buttonW, 40);
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
    if ([self validateAccountAndPwd]) {
        [self loadingWithText:@"登录中"];
        
//        NSDictionary *param = @{@"username":self.accountField.text,@"password":self.passwordField.text};
        NSDictionary *param = @{@"mobilePhoneNumber":self.accountField.text,@"password":self.passwordField.text};
//        NSDictionary *param = @{@"mobilePhoneNumber":self.accountField.text,@"smsCode":@"913667"};
        
        [[HttpConnection defaultConnection] userLoginWithParam:param completion:^(NSDictionary *data, NSError *error) {
            [self hideHUD];
            
            if (!error) {
                [CustomiseTool setIsLogin:YES];
                [CustomiseTool setLoginToken:data[@"sessionToken"]];
                
                [[UserManager shareManager] updateUserWithDict:data];
                [UserManager cacheToDisk];
                
                [self dismissLoginController];
            } else {
                [self showErrorWithError:error];
            }
        }];
    }
}

- (void)quickRegisterClick:(UIButton *)button {
    CodeLoginViewController *controller = [[CodeLoginViewController alloc] init];
    controller.LoginSuccessBlock = ^{
        self.LoginDismissBlock();
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)forgetClick {
//    [self showAlertWithTitle:nil message:@"怪我咯😂" operationTitle:@"知道了" operation:nil];
    
    FindPasswordController *controller = [[FindPasswordController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
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
    if (textField == self.accountField && textField.text.length > 11) {
        textField.text = [textField.text substringToIndex:11];
        
    } else if (textField == self.passwordField && textField.text.length > 12) {
        textField.text = [textField.text substringToIndex:12];
        
    }
    self.loginButton.enabled = (self.accountField.text.length == 11 && self.passwordField.text.length >= 6);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
