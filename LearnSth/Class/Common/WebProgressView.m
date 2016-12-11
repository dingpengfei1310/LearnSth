//
//  WebProgressView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "WebProgressView.h"

@interface WebProgressView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation WebProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self.layer addSublayer:self.gradientLayer];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress {
    self.gradientLayer.position = CGPointMake(CGRectGetWidth(self.frame) * progress, CGRectGetHeight(self.frame) * 0.5);
}

#pragma mark
- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        CGFloat height = CGRectGetHeight(self.frame);
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = self.bounds;
        
        _gradientLayer.anchorPoint = CGPointMake(1.0, height * 0.5);
        _gradientLayer.position = CGPointMake(0, height * 0.5);
        _gradientLayer.startPoint = CGPointMake(0.5, 0.5);
        _gradientLayer.endPoint = CGPointMake(1.0, 0.5);
        
        _gradientLayer.cornerRadius = height * 0.5;
        _gradientLayer.locations = @[@0.8,@0.8,@1.0];
        _gradientLayer.colors = @[
                                  (id)[UIColor clearColor].CGColor,
                                  (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor,
                                  (id)[UIColor whiteColor].CGColor
                                  ];
    }
    return _gradientLayer;
}


@end
