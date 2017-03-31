//
//  UIView+Tool.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/30.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "UIView+Tool.h"
#import "MBProgressHUD.h"

@implementation UIView (Tool)

#pragma mark - HUD提示框
- (void)loading {
    [self showMessage:nil toView:self];
}

- (void)loadingWithText:(NSString *)text {
    [self showMessage:text toView:self];
}

- (void)showMessage:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    }
    
    hud.label.text = message;
    hud.label.font = [self hudTextFont];
    hud.margin = [self hudTextMargin];
    
    hud.bezelView.color = [UIColor clearColor];
    hud.mode = MBProgressHUDModeText;
    hud.contentColor = [UIColor whiteColor];
    hud.bezelView.backgroundColor = [UIColor blackColor];
}

- (void)showSuccess:(NSString *)success {
    [self show:success toView:self];
}

- (void)showError:(NSString *)error {
    [self show:error toView:self];
}

- (void)showErrorWithError:(NSError *)error {
    NSString *messege = [error.userInfo objectForKey:@"message"];
    if(!messege) {
        messege = @"网络异常";
    }
    [self showError:messege];
}

- (void)hideHUD {
    [self hideHUDForView:self];
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
    return 10;
}

@end
