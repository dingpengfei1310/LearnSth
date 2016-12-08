//
//  PopoverViewController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/26.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "BaseViewController.h"

@class PopoverViewController;

@protocol PopoverViewControllerDelegate <NSObject>

- (void)controller:(PopoverViewController *)controller didSelectAtIndex:(NSInteger)index;

@end

@interface PopoverViewController :BaseViewController

@property (nonatomic, copy) NSArray *dataArray;

@property (nonatomic, weak) id<PopoverViewControllerDelegate> delegate;

@end