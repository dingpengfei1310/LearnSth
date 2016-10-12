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
- (UIImage *)imageBrowser:(DDImageBrowserView *)imageBrowser placeholderImageOfIndex:(NSInteger)index;

@optional
- (NSURL *)imageBrowser:(DDImageBrowserView *)imageBrowser imageUrlOfIndex:(NSInteger)index;

@end



@interface DDImageBrowserView : UIView
@property (nonatomic, assign) NSInteger imageCount;

@property (nonatomic, weak) id<DDImageBrowserDelegate> imageBrowserDelegate;

- (void)show;

- (void)selectImageOfIndex:(NSInteger)index;

@end
