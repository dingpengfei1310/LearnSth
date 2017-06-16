//
//  LiveInfoViewController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/6/16.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LiveModel;
@interface LiveInfoViewController : UIViewController

@property (nonatomic, copy) void (^LiveInfoDismissBlock)();
@property (nonatomic, strong) LiveModel *liveModel;

@end
