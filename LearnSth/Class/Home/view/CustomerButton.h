//
//  CustomerButton.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/25.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ImagePoisition) {
    ImagePoisitionDefault,
    ImagePoisitionTop,
    ImagePoisitionLeft,
    ImagePoisitionBottom,
    ImagePoisitionRight,
};

@interface CustomerButton : UIButton

- (void)setImagePoisition:(ImagePoisition)position;

@end
