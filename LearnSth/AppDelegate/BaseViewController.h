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

#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"

@interface BaseViewController : UIViewController

/**
 *  导航栏设为透明
 */
- (void)navigationBarColorClear;

/**
 *  导航栏恢复
 */
- (void)navigationBarColorRestore;

///
- (void)loading;

- (void)showSuccess:(NSString *)success;
- (void)showError:(NSString *)error;
- (void)showMessage:(NSString *)message;

- (void)hideHUD;

@end
