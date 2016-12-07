//
//  UITableView+Tool.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/5.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ReloadClickBlock)(void);

@interface UITableView (Tool)

@property (nonatomic, copy) ReloadClickBlock clickBlock;

- (void)checkEmpty;

@end


