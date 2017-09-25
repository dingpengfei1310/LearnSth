//
//  UIViewController+Tool.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/1/6.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;
@interface UIViewController (Tool)

#pragma mark - 导航栏
///导航栏设为透明
- (void)navigationBarColorClear;
///导航栏恢复
- (void)navigationBarColorRestore;
///导航栏背景
- (void)navigationBarBackgroundImage:(UIImage *)image;

#pragma mark - HUD提示框
///加载
- (void)loading;
- (void)loadingWithText:(NSString *)text;

- (void)loadingWithText:(NSString *)text cancelBlock:(void (^)(void))cancel;

///自动消失的文字提示框
- (void)showSuccess:(NSString *)success;
- (void)showError:(NSString *)error;
- (void)showErrorWithError:(NSError *)error;

///隐藏
- (void)hideHUD;
- (void)hideHUDAnimation;

#pragma mark - 确认弹出框
///没有访问权限时的弹出框
- (void)showAuthorizationStatusDeniedAlertMessage:(NSString *)message;
///弹出框(确定)
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message operationTitle:(NSString *)operationTitle operation:(void (^)(void))operation;
///通用弹出框(取消－确定)
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancel:(void (^)(void))cancel operation:(void (^)(void))operation;
///通用弹出框(取消－确定。“确定”为红色字体，危险操作，退出、删除等)
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancel:(void (^)(void))cancel destructive:(void (^)(void))operation;

///弹出框(自定义标题，内容，按钮)
//- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle cancel:(void (^)())cancel operationTitle:(NSString *)operationTitle operation:(void (^)())operation style:(UIAlertActionStyle)style;

@end
