//
//  UIView+SparkAnimation.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/7/27.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,SparkType) {
    SparkTypeCircle,
    SparkTypeRectangle
};

@interface UIView (SparkAnimation)

- (void)startSparkAnimation:(SparkType)type;

@end
