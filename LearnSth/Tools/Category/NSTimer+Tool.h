//
//  NSTimer+Tool.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/7/13.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^TimerBlock)(NSTimer *timer);

@interface NSTimer (Tool)

+ (instancetype)dd_timerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo block:(TimerBlock)block;

@end
