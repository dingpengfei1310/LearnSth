//
//  UIButton+Tool.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ImagePoisition) {
    ImagePoisitionTop,
    ImagePoisitionLeft,
    ImagePoisitionBottom,
    ImagePoisitionRight,
};

@interface UIButton (Tool)

- (void)setImagePoisition:(ImagePoisition)position;

@end
