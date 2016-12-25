//
//  PopoverViewController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/26.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "BaseViewController.h"

@interface PopoverViewController :BaseViewController

@property (nonatomic, copy) void (^SelectIndex)(NSInteger index);

@property (nonatomic, copy) NSArray *dataArray;
@property (nonatomic, strong) UIPopoverPresentationController *popover;

@end
