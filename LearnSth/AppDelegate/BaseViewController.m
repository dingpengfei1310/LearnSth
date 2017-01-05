//
//  BaseViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "BaseViewController.h"

#import "MBProgressHUD.h"
#import "UIImage+Tool.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

