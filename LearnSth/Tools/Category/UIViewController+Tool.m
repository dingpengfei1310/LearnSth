//
//  UIViewController+Tool.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/1/6.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "UIViewController+Tool.h"
#import "MBProgressHUD.h"
#import <objc/runtime.h>

static char CancelKey;

typedef void (^CancelBlock)();

@implementation UIViewController (Tool)

#pragma mark
- (void)navigationBarColorClear {
    UIImage *image = [CustomiseTool imageWithColor:[UIColor clearColor]];
    
    [self.navigationController.navigationBar setBackgroundImage:image
                                                  forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:image];
}

- (void)navigationBarColorRestore {
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

#pragma mark - HUD提示框
- (void)loading {
    [self showMessage:nil toView:nil];
}

- (void)loadingWithText:(NSString *)text {
    [self showMessage:text toView:nil];
}

- (void)loadingWithText:(NSString *)text cancelBlock:(void (^)())cancel {
    UIView *view = [[UIApplication sharedApplication].windows lastObject];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = text;
    hud.label.font = [self hudTextFont];
    hud.margin = [self hudTextMargin];
    
    hud.bezelView.color = [UIColor clearColor];
    hud.animationType = MBProgressHUDAnimationZoom;
    
    if (text.length > 0) {
        hud.mode = MBProgressHUDModeText;
        hud.contentColor = [UIColor whiteColor];
        hud.bezelView.color = [UIColor blackColor];
    }
    
    UIButton *button = hud.button;
    button.titleLabel.font = [self hudTextFont];
    button.layer.borderWidth = 0.0;
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    objc_setAssociatedObject(button, &CancelKey, cancel, OBJC_ASSOCIATION_COPY);
}

- (void)showSuccess:(NSString *)success {
    [self show:success toView:nil];
}

- (void)showError:(NSString *)error {
    [self show:error toView:nil];
}

- (void)showErrorWithError:(NSError *)error {
    NSString *messege = [error.userInfo objectForKey:@"message"];
    messege = messege ?: @"网络异常";
    [self showError:messege];
}

- (void)hideHUD {
    [self hideHUDForView:nil];
}

#pragma mark
- (void)show:(NSString *)text toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = text;
    hud.label.font = [self hudTextFont];
    hud.contentColor = [UIColor whiteColor];
    hud.margin = [self hudTextMargin];
    
    hud.mode = MBProgressHUDModeCustomView;
    hud.animationType = MBProgressHUDAnimationZoom;
    
    hud.bezelView.backgroundColor = [UIColor blackColor];
    
    [hud hideAnimated:YES afterDelay:1.0];
}

- (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    hud.label.font = [self hudTextFont];
    hud.margin = [self hudTextMargin];
    
    hud.bezelView.color = [UIColor clearColor];
    hud.animationType = MBProgressHUDAnimationZoom;
    
    if (message.length > 0) {
        hud.mode = MBProgressHUDModeText;
        hud.contentColor = [UIColor whiteColor];
        
        hud.bezelView.backgroundColor = [UIColor blackColor];
    }
    
    return hud;
}

- (void)hideHUDForView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    [MBProgressHUD hideHUDForView:view animated:YES];
}

- (UIFont *)hudTextFont {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    UIFont *textFont;
    if (screenW == 320.0) {
        textFont = [UIFont boldSystemFontOfSize:15];
    } else if (screenW == 375.0) {
        textFont = [UIFont boldSystemFontOfSize:16];
    } else {
        textFont = [UIFont boldSystemFontOfSize:17];
    }
    
    return textFont;
}

- (CGFloat)hudTextMargin {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat margin;
    if (screenW == 320.0) {
        margin = 13;
    } else if (screenW == 375.0) {
        margin = 15;
    } else {
        margin = 17;
    }
    return margin;
}

- (void)buttonClick:(UIButton *)button {
    [self hideHUD];
    
    CancelBlock cancelBlock = objc_getAssociatedObject(button, &CancelKey);
    if (cancelBlock) {
        cancelBlock();
    }
}

#pragma mark - 确认弹出框
- (void)openSystemSetting {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)showAuthorizationStatusDeniedAlertMessage:(NSString *)message cancel:(void (^)())cancel operation:(void (^)())operation {
    NSString *mess = [NSString stringWithFormat:@"%@\n%@",message,@"您可以到“隐私设置“中启用访问"];
    void (^operationBlock)() = ^{
        [self openSystemSetting];
        operation ? operation() : 0;
    };
    
    [self showAlertWithTitle:@"提示" message:mess cancelTitle:@"知道了" cancel:cancel operationTitle:@"去设置" operation:operationBlock style:UIAlertActionStyleDefault];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message operationTitle:(NSString *)operationTitle operation:(void (^)())operation {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:operationTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        operation ? operation() : 0;
    }];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancel:(void (^)())cancel operation:(void (^)())operation {
    [self showAlertWithTitle:nil message:message cancelTitle:@"取消" cancel:cancel operationTitle:@"确定" operation:operation style:UIAlertActionStyleDefault];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancel:(void (^)())cancel destructive:(void (^)())operation {
    [self showAlertWithTitle:nil message:message cancelTitle:@"取消" cancel:cancel operationTitle:@"确定" operation:operation style:UIAlertActionStyleDestructive];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle cancel:(void (^)())cancel operationTitle:(NSString *)operationTitle operation:(void (^)())operation style:(UIAlertActionStyle)style {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelA = [UIAlertAction actionWithTitle:cancelTitle
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * action) {
                                                        cancel ? cancel() : 0;
                                                    }];
    UIAlertAction *operationA  = [UIAlertAction actionWithTitle:operationTitle
                                                          style:style
                                                        handler:^(UIAlertAction * action) {
                                                            operation ? operation() : 0;
                                                        }];
    [alert addAction:cancelA];
    [alert addAction:operationA];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
