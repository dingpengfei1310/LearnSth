//
//  LivePlayerViewController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/9/3.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "BaseViewController.h"

@class LiveModel;
@interface LivePlayerViewController : BaseViewController

@property (nonatomic, copy) void (^PlayerDismissBlock)();

@property (strong, nonatomic) LiveModel *liveModel;

@end
