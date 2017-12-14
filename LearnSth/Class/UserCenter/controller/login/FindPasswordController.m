//
//  FindPasswordController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/8/30.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "FindPasswordController.h"

#import "TPKeyboardAvoidingScrollView.h"
#import "HttpConnection.h"
#import "NSString+Tool.h"
#import "UIImage+Tool.h"

@interface FindPasswordController ()

@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UITextField *rePwdField;

@property (nonatomic, strong) UIButton *submitButton;

@end

@implementation FindPasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"找回密码";
    
    [self initSubView];
}

- (void)initSubView {
    CGFloat barH = NavigationBarH + StatusBarH;
    CGRect frame = CGRectMake(0, barH, Screen_W, Screen_H - barH);
    
    TPKeyboardAvoidingScrollView *scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:frame];
    [self.view addSubview:scrollView];
    
    CGFloat space = 40;
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(space, space, Screen_W - space * 2, 36)];
    _passwordField.borderStyle= UITextBorderStyleRoundedRect;
    _passwordField.placeholder = @"请输入密码";
    _passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passwordField.keyboardType = UIKeyboardTypeASCIICapable;
    _passwordField.clearsOnBeginEditing = NO;
    _passwordField.secureTextEntry = YES;
    [_passwordField addTarget:self action:@selector(textFieldValueChange:) forControlEvents:UIControlEventEditingChanged];
    [scrollView addSubview:_passwordField];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(space, CGRectGetMaxY(_passwordField.frame), Screen_W - space * 2, 20)];
    tipLabel.text = @"密码为6-12位数字和字母,不能为纯数字";
    tipLabel.textColor = KBaseTextColor;
    tipLabel.font = [UIFont systemFontOfSize:13];
    [scrollView addSubview:tipLabel];
    
    //
    _submitButton = [[UIButton alloc] initWithFrame:CGRectMake(space, CGRectGetMaxY(tipLabel.frame) + 20, Screen_W - space * 2, 48)];
    _submitButton.enabled = NO;
    UIImage *image = [UIImage imageWithColor:KBaseAppColor];
    UIImage *cornerImage = [image cornerImageWithSize:_submitButton.frame.size radius:3];
    [_submitButton setBackgroundImage:cornerImage forState:UIControlStateNormal];
    [_submitButton setTitle:@"确定" forState:UIControlStateNormal];
    [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_submitButton addTarget:self action:@selector(findPassword) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.submitButton];
}

- (void)findPassword {
    if (![self.passwordField.text validatePassword]) {
        [self showError:@"密码格式不正确"];
        return;
    }
    
    [self loading];
    
//    NSDictionary *param = @{@"password":@"d888888",@"code":@"913667"};
    NSDictionary *param = @{@"password":_passwordField.text,@"code":@"913667"};
    [[HttpConnection defaultConnection] userFindPasswordWithParam:param Completion:^(NSDictionary *data, NSError *error) {
        [self hideHUD];
        if (error) {
            [self showErrorWithError:error];
        } else {
            [self showSuccess:@"密码修改成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark
- (void)textFieldValueChange:(UITextField *)textField {
    if (textField.text.length > 12) {
        textField.text = [textField.text substringToIndex:12];
    }
    self.submitButton.enabled = (self.passwordField.text.length >= 6);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
