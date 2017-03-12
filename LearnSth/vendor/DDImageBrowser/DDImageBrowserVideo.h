//
//  DDImageBrowserVideo.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/2/9.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;
@interface DDImageBrowserVideo : UIViewController

@property (nonatomic, strong) PHAsset *asset;//播放相册视频
@property (nonatomic, strong) NSString *filePath;//播放文件视频

@end
