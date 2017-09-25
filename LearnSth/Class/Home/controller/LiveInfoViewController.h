//
//  LiveInfoViewController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/6/16.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "BaseViewController.h"

@class LiveModel;
@interface LiveInfoViewController : BaseViewController

@property (nonatomic, copy) void (^LiveInfoDismissBlock)(void);
@property (nonatomic, strong) LiveModel *liveModel;

@end
