//
//  VideoPlayerController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/13.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPlayerController : UIViewController

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) void (^BackBlock)();

@end