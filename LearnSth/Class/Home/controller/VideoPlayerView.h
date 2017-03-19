//
//  VideoPlayerView.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/18.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPlayerView : UIView

@property (nonatomic, copy) void (^BackBlock)();
@property (nonatomic, copy) void (^FullScreenBlock)();
@property (nonatomic, copy) void (^TapGestureBlock)();

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) NSString *name;

- (void)pausePlayer;

@end
