//
//  DDImageBrowserController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/14.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class DDImageBrowserController;

@protocol DDImageBrowserDelegate <NSObject>

@optional

//占位图片。作用同thumbImages。。如果都不设置，则不会显示
- (UIImage *)controller:(DDImageBrowserController *)controller placeholderImageOfIndex:(NSInteger)index;

//网络图片地址
- (NSURL *)controller:(DDImageBrowserController *)controller imageUrlOfIndex:(NSInteger)index;

//滑动的操作
- (void)controller:(DDImageBrowserController *)controller didScrollToIndex:(NSInteger)index;

//点击的操作
- (void)controller:(DDImageBrowserController *)controller didSelectAtIndex:(NSInteger)index;

@end


@interface DDImageBrowserController : UIViewController

@property (nonatomic, strong) NSArray *thumbImages;//占位图，和代理方法作用一样。同时设置时，优先级高于代理方法

//图片数量
@property (nonatomic, assign) NSInteger imageCount;

@property (nonatomic, weak) id<DDImageBrowserDelegate> browserDelegate;

//默认为0，第一张
@property (nonatomic, assign) NSInteger currentIndex;

////显示高清图使用，显示对应页的高清图
//- (void)showHighQualityImageOfIndex:(NSInteger)index withImage:(UIImage *)image videoFlag:(BOOL)flag;

//显示高清图使用，显示对应页的高清图
- (void)showHighQualityImageOfIndex:(NSInteger)index WithAsset:(PHAsset *)asset;

@end
