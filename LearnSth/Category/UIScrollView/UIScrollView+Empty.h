//
//  UIScrollView+Empty.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2018/3/15.
//  Copyright © 2018年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ReloadClickBlock)(void);

@interface UIScrollView (Empty)

@property (nonatomic, copy) ReloadClickBlock clickBlock;

- (void)checkEmpty;

@end
