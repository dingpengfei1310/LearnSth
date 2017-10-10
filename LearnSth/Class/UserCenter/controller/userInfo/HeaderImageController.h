//
//  HeaderImageController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/17.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "BaseViewController.h"

@interface HeaderImageController : BaseViewController

@property (nonatomic, copy) void (^ChangeHeaderImageBlock)(void);

@end
