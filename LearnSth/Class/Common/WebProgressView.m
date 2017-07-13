//
//  WebProgressView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "WebProgressView.h"

@interface WebProgressView ()<CAAnimationDelegate>

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@end

@implementation WebProgressView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _width = CGRectGetWidth(self.frame);
        _height = CGRectGetHeight(self.frame);
        [self.layer addSublayer:self.gradientLayer];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    
    if (_progress == 1.0) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
        animation.delegate = self;
        animation.duration = 0.2;
        animation.fromValue = [NSValue valueWithCGRect:_gradientLayer.frame];
        animation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, _width, _height)];
        [_gradientLayer addAnimation:animation forKey:@"animation"];
    } else {
        _gradientLayer.frame = CGRectMake(0, 0, _width * _progress, _height);
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self removeFromSuperview];
}

#pragma mark
- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = CGRectZero;
        _gradientLayer.cornerRadius = _height * 0.5;
        
        _gradientLayer.startPoint = CGPointMake(0, 0.5);
        _gradientLayer.endPoint = CGPointMake(1.0, 0.5);
        
        _gradientLayer.locations = @[@0.0,@0.5,@1.0];
        _gradientLayer.colors = @[
                                  (id)[UIColor colorWithWhite:1.0 alpha:0.1].CGColor,
                                  (id)[UIColor colorWithWhite:1.0 alpha:0.5].CGColor,
                                  (id)[UIColor whiteColor].CGColor
                                  ];
    }
    return _gradientLayer;
}

@end
