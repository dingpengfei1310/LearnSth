//
//  DDImageCycleView.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/13.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ClickBlock)(NSInteger index);

//图片切换的方式
typedef enum {
    ChangeModeDefault,  //轮播滚动
    ChangeModeFade      //淡入淡出
} ChangeMode;




@interface DDImageCycleView : UIView

/**
 *  轮播的图片数组，可以是本地图片（UIImage，不能是图片名称），也可以是网络路径
 */
@property (nonatomic, strong) NSArray *imageArray;

@property (nonatomic, assign) ChangeMode changeMode;


@property (nonatomic, copy) ClickBlock imageClickBlock;



@end
