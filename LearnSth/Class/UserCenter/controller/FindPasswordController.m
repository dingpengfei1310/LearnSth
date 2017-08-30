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

@interface FindPasswordController () {
    CGFloat viewW;
}

@property (nonatomic, strong) UITextField *accountField;
@property (nonatomic, strong) UITextField *codeField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UITextField *rePwdField;

@end

@implementation FindPasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"找回密码";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(findPassword)];
    
    [self initSubView];
}

- (void)initSubView {
    viewW = [UIScreen mainScreen].bounds.size.width;
    TPKeyboardAvoidingScrollView *scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 64, viewW, Screen_H - 64)];
    [self.view addSubview:scrollView];
}

- (void)findPassword {
    [self loading];
    
    NSDictionary *param = @{@"password":@"d888888",@"code":@"913667"};
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
