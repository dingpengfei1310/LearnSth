//
//  AnimationView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "AnimationView.h"

@interface AnimationView ()<CAAnimationDelegate> {
    CGFloat width,height;
    CGFloat radius;
}

@property (nonatomic, strong) CAShapeLayer *baseCircleLayer;
@property (nonatomic, strong) NSMutableArray *progressLayers;

@end

CGFloat const lineWidth = 2.0;
CGFloat const totalDuration = 3.0;

@implementation AnimationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        width = CGRectGetWidth(frame);
        height = CGRectGetHeight(frame);
        radius = width * 0.5 - 10;
        
        if (radius > 0) {
            [self addBaseLayer];
            
            [self setGradientLayer];
            
            [self startProgress];
        }
        
    }
    return self;
}

- (void)addBaseLayer {
    _baseCircleLayer = [CAShapeLayer layer];
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width * 0.5, height * 0.5)
                                                              radius:radius
                                                          startAngle:0
                                                            endAngle:M_PI * 2
                                                           clockwise:YES];
    _baseCircleLayer.path = bezierPath.CGPath;
    _baseCircleLayer.lineWidth = lineWidth;
    _baseCircleLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    _baseCircleLayer.fillColor = self.backgroundColor.CGColor;
    
    [self.layer addSublayer:_baseCircleLayer];
    
}

#pragma mark
- (void)addProgressLayer {
    for (int i = 0; i < 3; i++) {
        CAShapeLayer *progressLayer = [CAShapeLayer layer];
        progressLayer.path = _baseCircleLayer.path;
        progressLayer.fillColor = [[UIColor clearColor] CGColor];
        progressLayer.strokeColor = [[self randomColor] CGColor];
        progressLayer.lineWidth = lineWidth;
        progressLayer.strokeEnd = 0.3 * (i + 1);
        progressLayer.strokeStart = 0.3 * i;
        
        [self.layer addSublayer:progressLayer];
        [self.progressLayers addObject:progressLayer];
    }
}

- (void)updateAnimations {
    
    for (int i = 0; i < self.progressLayers.count; i++) {
        CAShapeLayer *progressLayer = self.progressLayers[i];
        CABasicAnimation *strokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        strokeEnd.repeatCount = MAXFLOAT;
        strokeEnd.duration = totalDuration;
        strokeEnd.fromValue = @(progressLayer.strokeStart);
        strokeEnd.toValue = @(progressLayer.strokeEnd);
        strokeEnd.autoreverses = YES;
        [progressLayer addAnimation:strokeEnd forKey:@""];
    }
    
}

- (void)startColorfulProgress {
    if (!_progressLayers) {
        _progressLayers = [NSMutableArray array];
    }
    [_progressLayers removeAllObjects];
    
    [self addProgressLayer];
    [self updateAnimations];
}

#pragma mark
- (void)startProgress {
    [_baseCircleLayer removeAllAnimations];
    
    CABasicAnimation *strokeStart = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    strokeStart.delegate = self;
//    strokeStart.repeatCount = MAXFLOAT;
    strokeStart.duration = 2;
    strokeStart.fromValue = @(0);
    strokeStart.toValue = @(0.3);
    [_baseCircleLayer addAnimation:strokeStart forKey:@""];
    
    
    CABasicAnimation *strokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//    strokeEnd.delegate = self;
//    strokeEnd.repeatCount = MAXFLOAT;
    strokeEnd.duration = 2;
    strokeEnd.fromValue = @(0);
    strokeEnd.toValue = @(1);
    //执行一遍后，原路返回。。。。
    //    strokeEnd.autoreverses = YES;
    //同时使用才有效，保持动画结束的状态
    //    strokeEnd.removedOnCompletion = NO;
    //    strokeEnd.fillMode = kCAFillModeForwards;
    [_baseCircleLayer addAnimation:strokeEnd forKey:@""];
}

- (void)stopProgress {
    [_baseCircleLayer removeAllAnimations];
}

- (void)setGradientLayer {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, width, 5);
    [gradientLayer setStartPoint:CGPointMake(0.0, 0.5)];
    [gradientLayer setEndPoint:CGPointMake(1.0, 0.5)];
    [self.layer addSublayer:gradientLayer];
    
    NSMutableArray *colors = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        UIColor *color= [self randomColor];
        [colors addObject:(id)[color CGColor]];
    }
    [gradientLayer setColors:colors];
}

#pragma mark
- (void)animationDidStart:(CAAnimation *)anim {
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self setGradientLayer];
    [self startProgress];
}

#pragma mark
- (UIColor *)randomColor {
    NSInteger r = arc4random() % 255;
    NSInteger g = arc4random() % 255;
    NSInteger b = arc4random() % 255;
    
    return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1.0];
}


@end
