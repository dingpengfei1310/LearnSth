//
//  NSTimer+Tool.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/7/13.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "NSTimer+Tool.h"

@implementation NSTimer (Tool)

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo block:(TimerBlock)block {
    return [NSTimer timerWithTimeInterval:ti
                                   target:self
                                 selector:@selector(execute:)
                                 userInfo:[block copy]
                                  repeats:yesOrNo];
}

+ (void)execute:(NSTimer *)timer {
    TimerBlock block = timer.userInfo;
    if (block) {
        block(timer);
    }
}

@end
