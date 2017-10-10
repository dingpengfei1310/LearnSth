//
//  RegisterViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/8.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "CodeLoginViewController.h"

#import "UserManager.h"
#import "NSString+Tool.h"
#import "UIImage+Tool.h"
#import "HttpConnection.h"
#import "NSTimer+Tool.h"

@interface CodeLoginViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *accountField;
@property (weak, nonatomic) IBOutlet UITextField *codeField;

@property (strong, nonatomic) UILabel *accountLabel;

@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UITextView *ruleText;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fieldHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonHeight;

@end

@implementation CodeLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"验证码登录";
    
    [self initConfig];
}

- (void)initConfig {
    CGFloat leftM = self.leftMargin.constant;
    CGFloat fieldH = self.fieldHeight.constant;
    
    _accountField.rightViewMode = UITextFieldViewModeAlways;
    _accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fieldH * 1.5, fieldH * 0.8)];
    _accountLabel.userInteractionEnabled = YES;
    _accountLabel.backgroundColor = KBaseBlueColor;
    _accountLabel.textColor = [UIColor whiteColor];
    _accountLabel.textAlignment = NSTextAlignmentCenter;
    _accountLabel.font = [UIFont systemFontOfSize:13];
    _accountLabel.text = @"点击获取";
    _accountField.rightView = _accountLabel;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getVerifyCode)];
    [_accountLabel addGestureRecognizer:tapGesture];
    
    CGFloat buttonH = self.buttonHeight.multiplier * fieldH;
    UIImage *image = [CustomiseTool imageWithColor:KBaseBlueColor];
    UIImage *cornerImage = [image cornerImageWithSize:CGSizeMake(Screen_W - leftM * 2, buttonH) radius:3];
    [_registerButton setBackgroundImage:cornerImage forState:UIControlStateNormal];
    [_registerButton setTitle:@"登录" forState:UIControlStateNormal];
    [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    NSMutableAttributedString *attributedStringM = [[NSMutableAttributedString alloc] initWithString:@"登录即表示同意《相关协议》"];
    NSRange range = NSMakeRange(7, 6);
    [attributedStringM addAttribute:NSLinkAttributeName value:@"link" range:range];
//    [attributedStringM addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
    self.ruleText.attributedText = attributedStringM;
    self.ruleText.delegate = self;
}

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
            
            [self showSuccess:@"验证码获取成功"];
        }
    }];
}

- (IBAction)regClick:(UIButton *)sender {
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
            
            [[UserManager shareManager] setValuesForKeysWithDictionary:data];
            [UserManager updateUser];
            
            if (self.LoginSuccessBlock) {
                self.LoginSuccessBlock();
            }
        }
    }];
}

- (IBAction)textFieldValueChanged:(UITextField *)textField {
    if (textField == self.accountField) {
        if (textField.text.length > 11) {
            textField.text = [textField.text substringToIndex:11];
        }
    } else if (textField == self.codeField) {
        if (textField.text.length > 12) {
            textField.text = [textField.text substringToIndex:12];
        }
    }
    
    BOOL validateAccount = self.accountField.text.length == 11;
    BOOL validateCode = (self.codeField.text.length >= 6);
    
    self.registerButton.enabled = (validateAccount && validateCode);
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([URL.absoluteString isEqualToString:@"link"]) {
        [self showAlertWithTitle:nil message:@"没有协议😂" operationTitle:nil operation:nil];
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
