//
//  TabBarViewController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/27.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITabBarController

//切换语言后，重新加载
- (void)loadViewControllersWithSelectIndex:(NSInteger)index;

@end
