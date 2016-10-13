//
//  BaseViewController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConfiguration.h"

@interface BaseViewController : UIViewController

/**
 *  导航栏设为透明
 */
- (void)navigationBarColorClear;

/**
 *  导航栏恢复
 */
- (void)navigationBarColorRestore;

@end