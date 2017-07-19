//
//  RegisterViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/8.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "RegisterViewController.h"

#import "UserManager.h"
#import "NSString+Tool.h"
#import "UIImage+Tool.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *accountField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UITextField *rePwdField;

@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fieldHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonHeight;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注册";
    
    [self initConfig];
}

- (void)initConfig {
    CGFloat leftM = self.leftMargin.constant;
    CGFloat fieldH = self.fieldHeight.constant;
    
    _accountField.leftViewMode = UITextFieldViewModeAlways;
    UILabel *accountL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fieldH * 1.5, fieldH)];
    accountL.text = @"账号";
    _accountField.leftView = accountL;
    
    _pwdField.leftViewMode = UITextFieldViewModeAlways;
    UILabel *passwordL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fieldH * 1.5, fieldH)];
    passwordL.text = @"密码";
    _pwdField.leftView = passwordL;
    
    _rePwdField.leftViewMode = UITextFieldViewModeAlways;
    UILabel *rePasswordL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fieldH * 1.5, fieldH)];
    rePasswordL.text = @"确认";
    _rePwdField.leftView = rePasswordL;
    
    CGFloat buttonH = self.buttonHeight.multiplier * fieldH;
    UIImage *image = [CustomiseTool imageWithColor:KBaseBlueColor];
    UIImage *cornerImage = [image cornerImageWithSize:CGSizeMake(Screen_W - leftM * 2, buttonH) radius:3];
    [_registerButton setBackgroundImage:cornerImage forState:UIControlStateNormal];
    [_registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (IBAction)regClick:(UIButton *)sender {
    [self.view endEditing:YES];
    
    if (![self.accountField.text validatePhoneNumber]) {
        [self showError:@"手机号格式不正确"];
        return;
    }
    
    if (![self.pwdField.text validatePassword] || ![self.rePwdField.text validatePassword]) {
        [self showError:@"密码格式不正确"];
        return;
    }
    
    if (![self.pwdField.text isEqualToString:self.rePwdField.text]) {
        [self showError:@"2次密码不一致"];
        return;
    }
    
    NSString *password = [self.pwdField.text MD5String];
    [UserManager shareManager].mobile = self.accountField.text;
    [UserManager shareManager].password = password;
    [UserManager shareManager].username = @"我是谁";
    
    UIImage *image = [UIImage imageNamed:@"defaultHeader"];
    [UserManager shareManager].headerImageData = UIImagePNGRepresentation(image);
    [UserManager updateUser];
    
    [CustomiseTool setIsLogin:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)textFieldValueChanged:(UITextField *)textField {
    if (textField == self.accountField) {
        if (textField.text.length > 11) {
            textField.text = [textField.text substringToIndex:11];
        }
    } else if (textField == self.pwdField) {
        if (textField.text.length > 12) {
            textField.text = [textField.text substringToIndex:12];
        }
    } else if (textField == self.rePwdField) {
        if (textField.text.length > 12) {
            textField.text = [textField.text substringToIndex:12];
        }
    }
    
    self.registerButton.enabled = (self.accountField.text.length == 11 && self.pwdField.text.length >= 6 && self.rePwdField.text.length >= 6);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
