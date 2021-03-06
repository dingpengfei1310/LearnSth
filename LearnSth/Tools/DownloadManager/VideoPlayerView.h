//
//  VideoPlayerView.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/18.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayerItem;
@interface VideoPlayerView : UIView

@property (nonatomic, copy) void (^BackBlock)(void);
@property (nonatomic, copy) void (^FullScreenBlock)(void);
@property (nonatomic, copy) void (^TapGestureBlock)(void);

- (instancetype)initWithTitle:(NSString *)title playerItem:(AVPlayerItem *)playerItem;
- (instancetype)initWithTitle:(NSString *)title filePath:(NSString *)filePath;

- (void)pausePlayer;
//- (void)screenCapture;

@end
