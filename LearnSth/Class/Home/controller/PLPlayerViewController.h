//
//  PLPlayerViewController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LiveModel;
@interface PLPlayerViewController : UIViewController

@property (nonatomic, strong) LiveModel *live;
@property (nonatomic, copy) void (^PlayerDismissBlock)();

@end
