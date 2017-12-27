//
//  UIViewController+Tool.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/1/6.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "UIViewController+Tool.h"
#import "BaseConfigure.h"
#import "UIImage+Tool.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import <objc/runtime.h>

static char CancelKey;
typedef void (^CancelBlock)(void);

@implementation UIViewController (Tool)

#pragma mark
- (void)navigationBarColorClear {
    UIImage *image = [[UIImage alloc] init];
    [self.navigationController.navigationBar setBackgroundImage:image
                                                  forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:image];
}

- (void)navigationBarColorRestore {
    UIImage *image = [UIImage imageWithColor:KBaseAppColor];
    [self.navigationController.navigationBar setBackgroundImage:image
                                                  forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:image];
}

- (void)navigationBarBackgroundImage:(UIImage *)image {
    [self.navigationController.navigationBar setBackgroundImage:image
                                                  forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:image];
}

//+ (BOOL)resolveInstanceMethod:(SEL)sel {
//    if (sel == NSSelectorFromString(@"dddd")) {
//        Method mm = class_getInstanceMethod(self, @selector(errorM));
//        IMP ii = class_getMethodImplementation(self, @selector(errorM));
//        
//        class_addMethod(self, sel, ii, method_getTypeEncoding(mm));
//        return YES;
//    }
//    return [super resolveInstanceMethod:sel];
//}
//
//- (void)errorM {
//}
//
//- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
//    NSMethodSignature *signature = [NSMethodSignature methodSignatureForSelector:aSelector];
//    if (!signature) {
//        signature = [NSMethodSignature signatureWithObjCTypes:"v@:"];
//    }
//    return signature;
//}
//
//- (void)forwardInvocation:(NSInvocation *)anInvocation {
//}

#pragma mark - HUD提示框
- (void)loading {
    [self showMessage:nil toView:self.view hide:YES];
}

- (void)loadingWithText:(NSString *)text {
    [self showMessage:text toView:self.view hide:YES];
}

//- (void)loadingWithText:(NSString *)text cancelBlock:(void (^)(void))cancel {
//    UIView *view = [UIApplication sharedApplication].keyWindow;
//
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
//    hud.bezelView.color = [UIColor blackColor];
//    hud.contentColor = [UIColor whiteColor];
//
//    if (text.length > 0) {
//        hud.label.text = text;
//    }
//
//    UIButton *button = hud.button;
//    [button setTitle:@"取消" forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//    objc_setAssociatedObject(button, &CancelKey, cancel, OBJC_ASSOCIATION_COPY);
//}

- (void)showSuccess:(NSString *)success {
//    [self show:success toView:self.view];
    [self showMessage:success toView:self.view hide:YES];
}

- (void)showError:(NSString *)error {
//    [self show:error toView:self.view];
    [self showMessage:error toView:self.view hide:YES];
}

- (void)showErrorWithError:(NSError *)error {
    NSString *messege = [error.userInfo objectForKey:@"message"];
    messege = messege ?: @"网络异常";
    [self showError:messege];
}

- (void)hideHUD {
    [self hideHUDForView:self.view animated:NO];
}

- (void)hideHUDAnimation {
    [self hideHUDForView:self.view animated:YES];
}

#pragma mark
//- (void)show:(NSString *)text toView:(UIView *)view {
//    if (!view) {
//        view = [UIApplication sharedApplication].keyWindow;
//    }
//
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
//    hud.mode = MBProgressHUDModeText;
//    hud.bezelView.color = [UIColor blackColor];
//
//    hud.label.text = text;
//    hud.label.textColor = [UIColor whiteColor];
//
////    hud.label.font = [self hudTextFont];
////    hud.margin = [self hudTextMargin];
////    hud.contentColor = [UIColor whiteColor];
////    hud.animationType = MBProgressHUDAnimationZoom;
//
//    [hud hideAnimated:YES afterDelay:1.5];
//}

- (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view hide:(BOOL)hide {
    if (!view) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.bezelView.color = [UIColor blackColor];
    hud.contentColor = [UIColor whiteColor];
    
    if (message.length > 0) {
        hud.mode = MBProgressHUDModeText;
        hud.label.numberOfLines = 0;
        hud.label.text = message;
    }
    if (hide) {
        [hud hideAnimated:YES afterDelay:2.0];
    }
    
    return hud;
}

- (void)hideHUDForView:(UIView *)view animated:(BOOL)animated {
    if (!view) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    
    [MBProgressHUD hideHUDForView:view animated:animated];
}

- (UIFont *)hudTextFont {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    UIFont *textFont;
    if (screenW == 320.0) {
        textFont = [UIFont boldSystemFontOfSize:15];
    } else if (screenW == 375.0) {
        textFont = [UIFont boldSystemFontOfSize:16];
    } else {
        textFont = [UIFont boldSystemFontOfSize:17];
    }
    
    return textFont;
}

- (CGFloat)hudTextMargin {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat margin;
    if (screenW == 320.0) {
        margin = 13;
    } else if (screenW == 375.0) {
        margin = 15;
    } else {
        margin = 17;
    }
    return margin;
}

- (void)buttonClick:(UIButton *)button {
    [self hideHUD];
    
    CancelBlock cancelBlock = objc_getAssociatedObject(button, &CancelKey);
    if (cancelBlock) {
        cancelBlock();
    }
}

#pragma mark - 确认弹出框
- (void)openSystemSetting {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)showAuthorizationStatusDeniedAlertMessage:(NSString *)message {
    [self dismissViewControllerAnimated:NO completion:nil];
    
    NSString *mess = [NSString stringWithFormat:@"%@\n%@",message,@"您可以到“隐私-设置“中启用访问"];
    void (^operationBlock)(void) = ^{
        [self openSystemSetting];
    };
    
    [self showAlertWithTitle:nil message:mess cancelTitle:@"知道了" cancel:nil operationTitle:@"去设置" operation:operationBlock style:UIAlertActionStyleDefault];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message operationTitle:(NSString *)operationTitle operation:(void (^)(void))operation {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:operationTitle.length ? operationTitle : @"确定"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       operation ? operation() : 0;
                                                   }];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancel:(void (^)(void))cancel operation:(void (^)(void))operation {
    [self showAlertWithTitle:title message:message cancelTitle:@"取消" cancel:cancel operationTitle:@"确定" operation:operation style:UIAlertActionStyleDefault];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancel:(void (^)(void))cancel destructive:(void (^)(void))operation {
    [self showAlertWithTitle:title message:message cancelTitle:@"取消" cancel:cancel operationTitle:@"确定" operation:operation style:UIAlertActionStyleDestructive];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle cancel:(void (^)(void))cancel operationTitle:(NSString *)operationTitle operation:(void (^)(void))operation style:(UIAlertActionStyle)style {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelA = [UIAlertAction actionWithTitle:cancelTitle.length ? cancelTitle : @"取消"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * action) {
                                                        cancel ? cancel() : 0;
                                                    }];
    UIAlertAction *operationA  = [UIAlertAction actionWithTitle:operationTitle.length ? operationTitle : @"确定"
                                                          style:style
                                                        handler:^(UIAlertAction * action) {
                                                            operation ? operation() : 0;
                                                        }];
    [alert addAction:cancelA];
    [alert addAction:operationA];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
