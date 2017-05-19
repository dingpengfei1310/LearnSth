//
//  PhotoLiarbraryTableViewController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/11.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PhotoCollectionSubtype){
    PhotoCollectionSubtypeDefault = 0,
    PhotoCollectionSubtypeImage,
    PhotoCollectionSubtypeVideo
};

@interface PhotoLiarbraryController : UIViewController

@property (nonatomic, assign) PhotoCollectionSubtype subtype;

@end
