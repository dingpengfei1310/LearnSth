//
//  PhotosCollectionViewController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/11.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VideoScanType){
    VideoScanTypeNormal = 0,//普通效果
    VideoScanTypeFilter,//滤镜效果
    VideoScanTypeTransform//（转码，不是播放）加滤镜效果
};

@class PHAsset,PHFetchResult;

@interface PhotosCollectionController : UIViewController

@property (nonatomic, strong) PHFetchResult *fetchResult;//结果集，这里是PHAsset集合
@property (nonatomic, assign) VideoScanType scanType;//视频才有效，照片无效

@end
