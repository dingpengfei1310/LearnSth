//
//  AnimationView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "AnimationView.h"

@interface AnimationView () {
    CGFloat width,height;
}

@property (nonatomic, strong) UIView *pointView;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@end

@implementation AnimationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        width = CGRectGetWidth(frame);
        height = CGRectGetHeight(frame);
        
        _shapeLayer = [CAShapeLayer layer];
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-5, -5, 10, 10)
                                                              cornerRadius:5];
        _shapeLayer.path = bezierPath.CGPath;
        _shapeLayer.fillColor = [UIColor redColor].CGColor;
        [self.layer addSublayer:_shapeLayer];
        
        
        
        UIBezierPath *positionPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(width * 0.2, height * 0.2, width * 0.6, height * 0.6)];
        
        CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        keyFrameAnimation.path = positionPath.CGPath;
        keyFrameAnimation.repeatCount = MAXFLOAT;
        keyFrameAnimation.calculationMode = kCAAnimationPaced;//path,则Paced
        keyFrameAnimation.timingFunction = [CAMediaTimingFunction functionWithName:@"linear"];
        keyFrameAnimation.duration = 2;
        
        [_shapeLayer addAnimation:keyFrameAnimation forKey:@"circleAnimation"];
        
    }
    return self;
}




@end
