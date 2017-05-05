//
//  VideoPlayerController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/13.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DownloadModel;
@interface VideoPlayerController : UIViewController

@property (nonatomic, strong) DownloadModel *downloadModel;

@property (nonatomic, copy) void (^BackBlock)();

@end
