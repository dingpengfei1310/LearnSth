//
//  VideoPlayerController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/13.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPlayerController : UIViewController

@property (nonatomic, copy) void (^DismissBlock)(void);

@property (nonatomic, copy) NSString *fileUrl;

@end
