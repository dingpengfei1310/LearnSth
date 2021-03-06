//
//  ScanIDCardController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/7.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "BaseViewController.h"

@class IDCardInfo;
@interface ScanIDCardController : BaseViewController

@property (nonatomic, copy) void (^ScanResult)(IDCardInfo *cardInfo,UIImage *image);
@property (nonatomic, copy) void (^DismissBlock)(void);

@end
