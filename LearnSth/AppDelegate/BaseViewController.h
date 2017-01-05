//
//  BaseViewController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppConfiguration.h"
#import "Utils.h"

@interface BaseViewController : UIViewController {
    CGFloat ViewFrame_X;
}

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

@end

