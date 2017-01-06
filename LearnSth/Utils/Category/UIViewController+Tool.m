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
    hud.label.font = [UIFont systemFontOfSize:12];
    hud.contentColor = [UIColor whiteColor];
    hud.margin = 10;
    
    hud.mode = MBProgressHUDModeCustomView;
    hud.animationType = MBProgressHUDAnimationZoom;
    
    hud.bezelView.backgroundColor = [UIColor blackColor];
    
    [hud hideAnimated:YES afterDelay:1.0];
}

- (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    hud.label.font = [UIFont systemFontOfSize:14];
    hud.margin = 10;
    
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

#pragma mark
- (void)openSystemSetting {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)showAuthorizationStatusDeniedAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"没有访问权限！您可以到“隐私设置“中启用访问" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"知道了"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertAction *settingAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openSystemSetting];
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:settingAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end

