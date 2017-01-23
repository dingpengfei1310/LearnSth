//
//  UIViewController+Tool.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/1/6.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "UIViewController+Tool.h"
#import "MBProgressHUD.h"
#import "UIImage+Tool.h"

@implementation UIViewController (Tool)

#pragma mark
- (void)navigationBarColorClear {
    UIImage *image = [UIImage imageWithColor:[UIColor clearColor]];
    
    [self.navigationController.navigationBar setBackgroundImage:image
                                                  forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:image];
}

- (void)navigationBarColorRestore {
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

#pragma mark
- (void)loading {
    [self showMessage:nil toView:nil];
}

- (void)loadingWithText:(NSString *)text {
    [self showMessage:text toView:nil];
}

- (void)showSuccess:(NSString *)success {
    [self show:success toView:nil];
}

- (void)showError:(NSString *)error {
    [self show:error toView:nil];
}

- (void)showErrorWithError:(NSError *)error {
    NSString *messege = [error.userInfo objectForKey:@"message"];
    if(!messege) {
        messege = @"网络异常";
    }
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
    
    [hud hideAnimated:YES afterDelay:1.5];
}

- (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    hud.label.font = [self hudTextFont];
    hud.margin = [self hudTextMargin];
    
    hud.bezelView.backgroundColor = [UIColor clearColor];
    
    if (message) {
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
        textFont = [UIFont systemFontOfSize:13];
    } else if (screenW == 375.0) {
        textFont = [UIFont systemFontOfSize:15];
    } else {
        textFont = [UIFont systemFontOfSize:17];
    }
    
    return textFont;
}

- (CGFloat)hudTextMargin {
    return 15;
}

#pragma mark
- (void)openSystemSetting {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)showAuthorizationStatusDeniedAlert {
    [self showAlertWithTitle:@"提示" message:@"没有访问权限！\n您可以到“隐私设置“中启用访问" cancelTitle:@"知道了" operationTitle:@"去设置" block:^{
        [self openSystemSetting];
    }];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message block:(void (^)())operationBlock {
    [self showAlertWithTitle:title message:message cancelTitle:@"取消" operationTitle:@"确定" block:^{
        operationBlock();
    }];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle operationTitle:(NSString *)operationTitle block:(void (^)())operationBlock {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    UIAlertAction *operation = [UIAlertAction actionWithTitle:operationTitle
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          operationBlock();
                                                      }];
    [alert addAction:cancel];
    [alert addAction:operation];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end

