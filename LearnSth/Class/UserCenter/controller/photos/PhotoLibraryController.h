//
//  PhotoLibraryController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/11.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, PhotoCollectionSubtype){
    PhotoCollectionSubtypeDefault = 0,
    PhotoCollectionSubtypeImage,
    PhotoCollectionSubtypeVideo
};

@interface PhotoLibraryController : BaseViewController

@property (nonatomic, assign) PhotoCollectionSubtype subtype;
@property (nonatomic, strong) void (^LibraryDismissBlock)(void);

@end
