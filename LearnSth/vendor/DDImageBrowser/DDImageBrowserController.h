//
//  DDImageBrowserController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/14.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;

@interface DDImageBrowserController : UIViewController

//默认为0，第一张
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *thumbImages;

//滑动的操作
@property (nonatomic, copy) void (^ScrollToIndexBlock)(DDImageBrowserController *controller, NSInteger index);

//显示对应页的高清图
- (void)showHighQualityImageOfIndex:(NSInteger)index WithAsset:(PHAsset *)asset;

@end
