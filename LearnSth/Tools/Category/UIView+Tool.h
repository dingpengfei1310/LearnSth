//
//  UIView+Tool.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/30.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Tool)

#pragma mark - HUD提示框
///加载
- (void)loading;
- (void)loadingWithText:(NSString *)text;

///提示文字:(会查找是否存在HUD，找不到才会创建新的HUD)
- (void)showMessage:(NSString *)message;

///自动消失的文字提示框
- (void)showSuccess:(NSString *)success;
- (void)showError:(NSString *)error;
- (void)showErrorWithError:(NSError *)error;

///隐藏
- (void)hideHUD;

@end
