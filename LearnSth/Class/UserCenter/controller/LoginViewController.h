//
//  LoginViewController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/31.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (nonatomic, copy) void (^LoginDismissBlock)();
@property (nonatomic, copy) void (^LoginSuccessBlock)();

@end