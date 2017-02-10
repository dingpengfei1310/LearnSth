//
//  DDImageBrowserController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/14.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDImageBrowserController,PHAsset;

@protocol DDImageBrowserDelegate <NSObject>

@optional

//滑动的操作
- (void)controller:(DDImageBrowserController *)controller didScrollToIndex:(NSInteger)index;
//点击的操作
//- (void)controller:(DDImageBrowserController *)controller didSelectAtIndex:(NSInteger)index;

@end

@interface DDImageBrowserController : UIViewController

//默认为0，第一张
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSArray *thumbImages;

@property (nonatomic, weak) id<DDImageBrowserDelegate> browserDelegate;

//显示高清图使用，显示对应页的高清图
- (void)showHighQualityImageOfIndex:(NSInteger)index WithAsset:(PHAsset *)asset;

@end
