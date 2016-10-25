//
//  BaseViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark
- (void)navigationBarColorClear {
    UIImage *image = [self getImageWithColor:[UIColor clearColor]];
    
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:image];
}

- (void)navigationBarColorRestore {
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (UIImage *)getImageWithColor:(UIColor *)color {
    UIGraphicsBeginImageContext(CGSizeMake(1.0, 1.0));
    [color setFill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark
- (void)loading {
    [self showMessage:nil toView:nil];
}

- (void)showSuccess:(NSString *)success {
    [self showSuccess:success toView:nil];
}

- (void)showError:(NSString *)error {
    [self showError:error toView:nil];
}

- (void)showMessage:(NSString *)message {
    [self showMessage:message toView:nil];
}

- (void)hideHUD {
    [self hideHUDForView:nil];
}

#pragma mark
- (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = text;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
//    hud.animationType = MBProgressHUDAnimationZoom;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    hud.bezelView.backgroundColor = [UIColor lightGrayColor];
    
    // 1秒之后再消失
    [hud hideAnimated:YES afterDelay:1.0];
}

- (void)showSuccess:(NSString *)success toView:(UIView *)view {
    [self show:success icon:@"HUDsuccess.png" view:view];
}

- (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"HUDerror.png" view:view];
}

- (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    hud.bezelView.backgroundColor = [UIColor lightGrayColor];
    return hud;
}

- (void)hideHUDForView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    [MBProgressHUD hideHUDForView:view animated:YES];
}

@end
