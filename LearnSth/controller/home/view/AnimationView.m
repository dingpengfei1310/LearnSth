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

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

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
//            [self.layer addSublayer:self.baseCircleLayer];
//            [self roation];
            
//            [self startProgress];
            
            [self.layer addSublayer:self.gradientLayer];
            [self setGradientLayer];
            
        }
        
    }
    return self;
}

- (CAShapeLayer *)baseCircleLayer {
    if (!_baseCircleLayer) {
        _baseCircleLayer = [CAShapeLayer layer];
        _baseCircleLayer.lineWidth = lineWidth;
        _baseCircleLayer.bounds = self.bounds;
        _baseCircleLayer.fillColor = [UIColor clearColor].CGColor;
        _baseCircleLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        _baseCircleLayer.position = CGPointMake(width * 0.5, height * 0.5);
//        _baseCircleLayer.contentsScale = [UIScreen mainScreen].scale;
//        _baseCircleLayer.contentsCenter;
//        _baseCircleLayer.mask = nil;
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width * 0.5, height * 0.5)
                                                                  radius:radius
                                                              startAngle:0
                                                                endAngle:M_PI * 1.8
                                                               clockwise:YES];
        
        _baseCircleLayer.path = bezierPath.CGPath;
    }
    
    return _baseCircleLayer;
}

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = self.bounds;
        _gradientLayer.position = CGPointMake(width * 0.5, height * 0.5 + 10);
        [_gradientLayer setStartPoint:CGPointMake(0.0, 0.0)];
        [_gradientLayer setEndPoint:CGPointMake(1.0, 1.0)];
    }
    return _gradientLayer;
}

#pragma mark
- (void)roation {
    CABasicAnimation *strokeStart = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    strokeStart.repeatCount = MAXFLOAT;
    strokeStart.duration = 2;
    strokeStart.fromValue = @(0);
    strokeStart.toValue = @(M_PI * 2);
    [self.baseCircleLayer addAnimation:strokeStart forKey:@""];
}

#pragma mark
- (void)startProgress {
    [self.baseCircleLayer removeAllAnimations];
    
    CABasicAnimation *strokeStart = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
//    strokeStart.repeatCount = NSIntegerMax;
    strokeStart.duration = 2;
    strokeStart.fromValue = @(0);
    strokeStart.toValue = @(0.3);
    [self.baseCircleLayer addAnimation:strokeStart forKey:@""];
    
    
    CABasicAnimation *strokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEnd.repeatCount = NSIntegerMax;
    strokeEnd.duration = 2;
    strokeEnd.fromValue = @(0);
    strokeEnd.toValue = @(1);
    //执行一遍后，原路返回。。。。
    //    strokeEnd.autoreverses = YES;
    //同时使用才有效，保持动画结束的状态
    //    strokeEnd.removedOnCompletion = NO;
    //    strokeEnd.fillMode = kCAFillModeForwards;
    [self.baseCircleLayer addAnimation:strokeEnd forKey:@""];
}

- (void)stopProgress {
}

- (void)setGradientLayer {
    NSMutableArray *colors = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        UIColor *color= [self randomColor];
        [colors addObject:(id)[color CGColor]];
    }
    [self.gradientLayer setColors:colors];
    
//    UIBezierPath *bezier = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, width, 2)];
//    CAShapeLayer *layer = [CAShapeLayer layer];
//    layer.lineWidth = 0.1;
//    layer.fillColor = [UIColor whiteColor].CGColor;
//    layer.strokeColor = [UIColor whiteColor].CGColor;
//    layer.path = bezier.CGPath;
//    
//    self.gradientLayer.mask = layer;
    
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.foregroundColor = [UIColor blackColor].CGColor;
    textLayer.string = @"加载中\n哈哈哈\n成功了";
    textLayer.fontSize = 20;
    textLayer.wrapped = YES;
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    textLayer.frame = CGRectMake(0, 0, width, height);
    textLayer.alignmentMode = kCAAlignmentCenter;
    [self.gradientLayer setMask:textLayer];
    
//    CADisplayLink *disPalyLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(setColors)];
//    disPalyLink.frameInterval = 30;
//    [disPalyLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)setColors {
    NSMutableArray *colors = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        UIColor *color= [self randomColor];
        [colors addObject:(id)[color CGColor]];
    }
    [self.gradientLayer setColors:colors];
}


#pragma mark
- (void)animationDidStart:(CAAnimation *)anim {
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
}

#pragma mark
- (UIColor *)randomColor {
    NSInteger r = arc4random() % 255;
    NSInteger g = arc4random() % 200;
    NSInteger b = arc4random() % 100;
    
    return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1.0];
}


@end


