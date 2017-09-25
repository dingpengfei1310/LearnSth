//
//  VideoPlayerView.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/18.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPlayerView : UIView

@property (nonatomic, copy) void (^BackBlock)(void);
@property (nonatomic, copy) void (^FullScreenBlock)(void);
@property (nonatomic, copy) void (^TapGestureBlock)(void);

@property (nonatomic, copy) NSString *fileUrl;
@property (nonatomic, copy) NSString *fileName;

- (void)pausePlayer;
//- (void)screenCapture;

@end
