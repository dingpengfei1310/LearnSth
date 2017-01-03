//
//  PhotosCollectionViewController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/11.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "BaseViewController.h"
#import <Photos/Photos.h>

@interface PhotosCollectionController : BaseViewController

@property (nonatomic, strong) PHAssetCollection *assetCollection;//一个相册或相册集合
@property (nonatomic, strong) PHFetchResult<PHAsset *> *fetchResult;//结果集，这里是PHAsset集合

@end
