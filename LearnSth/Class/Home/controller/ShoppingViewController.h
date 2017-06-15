//
//  ShoppingViewController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/2/8.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShoppingViewController : UIViewController

@property (nonatomic, copy) void (^BackItemBlock)();//返回操作。不设置则为默认返回

@end
