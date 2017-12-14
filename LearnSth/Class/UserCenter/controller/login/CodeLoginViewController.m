//
//  RegisterViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/8.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "CodeLoginViewController.h"

#import "TPKeyboardAvoidingScrollView.h"
#import "UserManager.h"
#import "NSString+Tool.h"
#import "UIImage+Tool.h"
#import "HttpConnection.h"
#import "NSTimer+Tool.h"

@interface CodeLoginViewController ()<UITextViewDelegate> {
    CGFloat topSpace;//页面上方空白高度
    CGFloat fieldMargin;//左右边距
    CGFloat fieldHeight;//输入框和登录按钮高度
    
    NSInteger timeCount;
}

@property (strong, nonatomic) UITextField *accountField;
@property (strong, nonatomic) UILabel *accountLabel;
@property (strong, nonatomic) UITextField *codeField;

@property (nonatomic, strong) UIButton *loginButton;

@end

@implementation CodeLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"验证码登录";
    
    [self initSubView];
}

- (void)initSubView {
    topSpace = 44;
    fieldMargin = 40;
    fieldHeight = 40;
    timeCount = 120;
    
    CGFloat barH = NavigationBarH + StatusBarH;
    CGRect frame = CGRectMake(0, barH, Screen_W, Screen_H - barH);
    TPKeyboardAvoidingScrollView *scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:frame];
    [self.view addSubview:scrollView];
    
    CGFloat filedW = Screen_W - fieldMargin * 2;
    //账号
    _accountField = [[UITextField alloc] initWithFrame:CGRectMake(fieldMargin, topSpace, filedW, fieldHeight)];
    _accountField.placeholder = @"请输入手机号";
    _accountField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _accountField.keyboardType = UIKeyboardTypeNumberPad;
    [_accountField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [scrollView addSubview:self.accountField];
    
    _accountField.rightViewMode = UITextFieldViewModeAlways;
    _accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fieldHeight * 1.5, fieldHeight * 0.8)];
    _accountLabel.userInteractionEnabled = YES;
    _accountLabel.backgroundColor = KBaseAppColor;
    _accountLabel.textColor = [UIColor whiteColor];
    _accountLabel.textAlignment = NSTextAlignmentCenter;
    _accountLabel.font = [UIFont systemFontOfSize:13];
    _accountLabel.text = @"点击获取";
    _accountField.rightView = _accountLabel;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getVerifyCode)];
    [_accountLabel addGestureRecognizer:tapGesture];
    
    UIView *accountLine = [[UIView alloc] initWithFrame:CGRectMake(fieldMargin, CGRectGetMaxY(_accountField.frame), filedW, 1.0)];
    accountLine.backgroundColor = KBackgroundColor;
    [scrollView addSubview:accountLine];
    
    //验证码
     _codeField = [[UITextField alloc] initWithFrame:CGRectMake(fieldMargin, CGRectGetMaxY(_accountField.frame), filedW, fieldHeight)];
    _codeField.placeholder = @"请输入验证码";
    _codeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _codeField.keyboardType = UIKeyboardTypeNumberPad;;
    [_codeField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [scrollView addSubview:self.codeField];
    
    UIView *pwdLine = [[UIView alloc] initWithFrame:CGRectMake(fieldMargin, CGRectGetMaxY(_codeField.frame), filedW, 1.0)];
    pwdLine.backgroundColor = KBackgroundColor;
    [scrollView addSubview:pwdLine];
    
    //登录按钮
    CGFloat loginButtonY = CGRectGetMaxY(_codeField.frame)+ fieldMargin;
    _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(fieldMargin, loginButtonY, filedW, fieldHeight * 1.2)];
    _loginButton.enabled = NO;
    UIImage *image = [UIImage imageWithColor:KBaseAppColor];
    UIImage *cornerImage = [image cornerImageWithSize:_loginButton.frame.size radius:3];
    [_loginButton setBackgroundImage:cornerImage forState:UIControlStateNormal];
    [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(loginClick:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.loginButton];
}

#pragma mark
- (void)getVerifyCode {
    if (![self.accountField.text validatePhoneNumber]) {
        [self showError:@"手机号格式不正确"];
        return;
    }
    
    [self loading];
    NSDictionary *param = @{@"mobilePhoneNumber":self.accountField.text};
    [[HttpConnection defaultConnection] userGetSMSCodeWithParam:param completion:^(NSDictionary *data, NSError *error) {
        [self hideHUD];
        
        if (error) {
            [self showError:@"验证码获取失败"];
        } else {
            self.accountLabel.userInteractionEnabled = NO;
            self.accountLabel.backgroundColor = KBaseTextColor;
            self.accountLabel.text = [NSString stringWithFormat:@"%ld",timeCount];
            
            [self showSuccess:@"验证码获取成功"];
            
            NSTimer *codeTimer = [NSTimer dd_timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer *timer) {
                timeCount--;
                if (timeCount > 0) {
                    self.accountLabel.text = [NSString stringWithFormat:@"%ld",timeCount];
                } else {
                    [timer invalidate];
                    timeCount = 120;
                    self.accountLabel.text = @"点击获取";
                    self.accountLabel.userInteractionEnabled = YES;
                    self.accountLabel.backgroundColor = KBaseAppColor;
                }
            }];
            
            [[NSRunLoop currentRunLoop] addTimer:codeTimer forMode:NSDefaultRunLoopMode];
        }
    }];
}

- (void)loginClick:(UIButton *)sender {
    [self.view endEditing:YES];
    
    if (![self.accountField.text validatePhoneNumber]) {
        [self showError:@"手机号格式不正确"];
        return;
    }
    
    [self loading];
//    NSDictionary *param = @{@"username":self.accountField.text,@"password":self.pwdField.text,@"mobilePhoneNumber":self.accountField.text};
//    [[HttpConnection defaultConnection] userRegisterWithParam:param completion:^(NSDictionary *data, NSError *error) {
//        [self hideHUD];
//        
//        if (error) {
//            [self showErrorWithError:error];
//        } else {
//            [CustomiseTool setIsLogin:YES];
//            
//            [UserManager shareManager].mobilePhoneNumber = self.accountField.text;
//            [UserManager shareManager].username = self.accountField.text;
//            
//            [UserManager updateUser];
//            
//            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//        }
//    }];
    
    NSDictionary *param = @{@"mobilePhoneNumber":self.accountField.text,@"smsCode":self.codeField.text};
    [[HttpConnection defaultConnection] userLoginWithSMSCode:param completion:^(NSDictionary *data, NSError *error) {
        [self hideHUD];
        if (error) {
            [self showErrorWithError:error];
        } else {
            [self showSuccess:@"登录成功"];
            
            [CustomiseTool setIsLogin:YES];
            [CustomiseTool setLoginToken:data[@"sessionToken"]];
            
            [[UserManager shareManager] updateUserWithDict:data];
            [UserManager cacheToDisk];
            
            if (self.LoginSuccessBlock) {
                self.LoginSuccessBlock();
            }
        }
    }];
}

#pragma mark
- (void)textFieldValueChanged:(UITextField *)textField {
    if (textField == self.accountField && textField.text.length > 11) {
        textField.text = [textField.text substringToIndex:11];
    }
    
    BOOL validateAccount = (self.accountField.text.length == 11);
    BOOL validateCode = (self.codeField.text.length > 0);
    self.loginButton.enabled = (validateAccount && validateCode);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
