//
//  NSDate+Tool.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/6/29.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "NSDate+Tool.h"
#import <sys/sysctl.h>

@implementation NSDate (Tool)

- (void)dd {
    struct timeval boottime;//上次设备重启时间，Unix time
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);
    
    struct timeval now;//现在时间，的Unix time
    struct timezone tz;
    gettimeofday(&now, &tz);
    
    double uptime = -1;//运行时间
    
    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0) {
        uptime = now.tv_sec - boottime.tv_sec;
        uptime += (double)(now.tv_usec - boottime.tv_usec) / 1000000.0;
    }
    
    //
    NSLog(@"%f",uptime);
}

@end
