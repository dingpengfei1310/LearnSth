//
//  DDImageBrowserView.h
//  ReadyJob
//
//  Created by 丁鹏飞 on 16/8/4.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDImageBrowserView;

@protocol DDImageBrowserDelegate <NSObject>

@required
//占位图片，首先显示的图片。。如果不需要网络图片或者高清图，实现这一个方法就可以
- (UIImage *)imageBrowser:(DDImageBrowserView *)imageBrowser placeholderImageOfIndex:(NSInteger)index;

@optional
//网络图片地址。。不实现此方法，会默认显示占位图
- (NSURL *)imageBrowser:(DDImageBrowserView *)imageBrowser imageUrlOfIndex:(NSInteger)index;

//实现此方法，可以操作显示
- (void)imageBrowser:(DDImageBrowserView *)imageBrowser didScrollToIndex:(NSInteger)index;

@end



@interface DDImageBrowserView : UIView

@property (nonatomic, assign) NSInteger imageCount;
@property (nonatomic, strong) NSArray *highQualityImages;//清晰大图，可以为空
@property (nonatomic, weak) id<DDImageBrowserDelegate> imageBrowserDelegate;

- (void)show;

- (void)selectImageOfIndex:(NSInteger)index;

- (void)setImageOfIndex:(NSInteger)index withImage:(UIImage *)image;


@end
