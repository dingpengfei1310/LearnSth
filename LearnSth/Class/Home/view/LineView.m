//
//  LineView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "LineView.h"

@interface LineView () {
    CGFloat width,height;
}

@property (nonatomic, strong) CAShapeLayer *lineLayer;

@property (nonatomic, assign) CGFloat topMargin;
@property (nonatomic, assign) CGFloat leftMargin;
@property (nonatomic, assign) CGFloat bottomMargin;
@property (nonatomic, assign) CGFloat rightMargin;

@property (nonatomic, assign) CGFloat minY;
@property (nonatomic, assign) CGFloat maxY;

@property (nonatomic, assign) CGFloat lineSpace;
@property (nonatomic, assign) CGFloat scaleY;


@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, assign) BOOL isFillColor;

@property (nonatomic, strong) NSMutableArray *lineArray;

@end

@implementation LineView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        width = CGRectGetWidth(frame);
        height = CGRectGetHeight(frame);
        
        _topMargin = 10;
        _leftMargin = 10;
        _bottomMargin = 10;
        _rightMargin = 10;
        
        _lineWidth = 1.0;
        _lineColor = KBaseBlueColor;
        _fillColor = KBaseTextColor;
//        _isFillColor = YES;
        
    }
    return self;
}

- (void)setDataArray:(NSArray *)dataArray {
    if (dataArray.count == 0) {
        return;
    }
    _dataArray = dataArray;
    
    self.lineSpace = (width - self.leftMargin - self.rightMargin) / (_dataArray.count - 1);
    NSNumber *min  = [_dataArray valueForKeyPath:@"@min.floatValue"];
    NSNumber *max = [_dataArray valueForKeyPath:@"@max.floatValue"];
    self.maxY = [max floatValue];
    self.minY  = [min floatValue];
    self.scaleY = (height - self.topMargin - self.bottomMargin) / (self.maxY - self.minY);
    
    self.lineArray = [NSMutableArray array];
    [_dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
        CGFloat value = [_dataArray[idx] floatValue];
        //        CGFloat xPostion = self.lineSpace * idx + self.leftMargin;
        CGFloat yPostion = (self.maxY - value) * self.scaleY + self.topMargin;
        
        [self.lineArray addObject:@(yPostion)];
    }];
    
    [self drawLineLayer];
}

#pragma mark
- (void)drawLineLayer {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [self.lineArray enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            [path moveToPoint:CGPointMake(self.lineSpace * idx + _leftMargin,obj.floatValue)];
        } else {
            [path addLineToPoint:CGPointMake(self.lineSpace * idx + _leftMargin,obj.floatValue)];
        }
    }];
    
    self.lineLayer = [CAShapeLayer layer];
    self.lineLayer.strokeColor = self.lineColor.CGColor;
    self.lineLayer.fillColor = [[UIColor clearColor] CGColor];
    if (_isFillColor) {
        self.lineLayer.fillColor = self.fillColor.CGColor;
        [path addLineToPoint:CGPointMake(width - _leftMargin ,height - _bottomMargin)];
        [path addLineToPoint:CGPointMake(_leftMargin ,height - _bottomMargin)];
    }
    self.lineLayer.path = path.CGPath;
    
    self.lineLayer.lineWidth = self.lineWidth;
    self.lineLayer.lineCap = kCALineCapRound;
    self.lineLayer.lineJoin = kCALineJoinRound;
    self.lineLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:self.lineLayer];
    
    [self startAnimation];
}

- (void)startAnimation {
    CABasicAnimation*pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 2.0f;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.fromValue = @0.0f;
    pathAnimation.toValue = @(1);
    [self.lineLayer addAnimation:pathAnimation forKey:nil];
}

@end
