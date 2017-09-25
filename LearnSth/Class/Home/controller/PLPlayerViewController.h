//
//  PLPlayerViewController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "BaseViewController.h"

@interface PLPlayerViewController : BaseViewController

@property (nonatomic, copy) void (^PlayerDismissBlock)(void);

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSArray *liveArray;

@end
