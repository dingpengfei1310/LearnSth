//
//  UIViewController+Tool.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/1/6.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Tool)

///导航栏设为透明
- (void)navigationBarColorClear;
///导航栏恢复
- (void)navigationBarColorRestore;

#pragma mark - HUD提示框
- (void)loading;
- (void)loadingWithText:(NSString *)text;

- (void)showSuccess:(NSString *)success;
- (void)showError:(NSString *)error;
- (void)showErrorWithError:(NSError *)error;

- (void)hideHUD;

//- (void)openSystemSetting;
- (void)showAuthorizationStatusDeniedAlert;
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message block:(void (^)())operationBlock;
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle operationTitle:(NSString *)operationTitle block:(void (^)())operationBlock;

@end
