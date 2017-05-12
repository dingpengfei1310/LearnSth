//
//  BaseChartView.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/5/12.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseChartView : UIView

@property (nonatomic, assign) CGFloat topMargin;
@property (nonatomic, assign) CGFloat leftMargin;
@property (nonatomic, assign) CGFloat bottomMargin;
@property (nonatomic, assign) CGFloat rightMargin;

@property (nonatomic, assign) CGFloat minY;
@property (nonatomic, assign) CGFloat maxY;

@property (nonatomic, assign) CGFloat scaleY;
@property (nonatomic, assign) CGFloat scaleX;

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIColor *fillColor;

@end
