//
//  UIView+SparkAnimation.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/7/27.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "UIView+SparkAnimation.h"
#import <objc/runtime.h>

static char LayerKey;

@implementation UIView (SparkAnimation)

- (void)startSparkAnimation:(SparkType)type {
    CAEmitterLayer *emitterLayer = self.emitterLayer;
    if (type == SparkTypeCircle) {
        emitterLayer.emitterShape = kCAEmitterLayerRectangle;
    } else if (type == SparkTypeRectangle) {
        emitterLayer.emitterShape = kCAEmitterLayerRectangle;
    }
    
    [self.layer addSublayer:emitterLayer];
    
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    cell.contents = (id)[UIImage imageNamed:@"lightDot"].CGImage;
    cell.color = [UIColor redColor].CGColor;
    
    cell.alphaRange = 0.2;
    cell.alphaSpeed = -0.1;
    
    cell.lifetime = 0.5;
    cell.lifetimeRange = 0.1;
    
    cell.birthRate = 1000;
    cell.velocity = 10;
    cell.velocityRange = 10;
    
    cell.scale = 0.1;
    cell.scaleRange = 0.1;
    
    emitterLayer.emitterCells = @[cell];
    emitterLayer.birthRate = 1.0;
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.repeatCount = 1;
    scaleAnimation.duration = 0.5;
    scaleAnimation.fromValue = @(0.8);
    scaleAnimation.toValue = @(1.3);
    scaleAnimation.removedOnCompletion = NO;
    scaleAnimation.fillMode = kCAFillModeForwards;
    [emitterLayer addAnimation:scaleAnimation forKey:@""];
    
    [self performSelector:@selector(stopCircleFire) withObject:nil afterDelay:0.5];
}

- (void)stopCircleFire {
    self.emitterLayer.birthRate = 0.0;
}

- (CAEmitterLayer *)emitterLayer {
    CAEmitterLayer *emitterLayer = objc_getAssociatedObject(self, &LayerKey);
    if (!emitterLayer) {
        CGSize size = self.frame.size;
        
        emitterLayer = [CAEmitterLayer layer];
        emitterLayer.position = CGPointMake(size.width * 0.5, size.height * 0.5);
        emitterLayer.emitterSize = size;
        emitterLayer.emitterMode = kCAEmitterLayerOutline;
//        emitterLayer.emitterShape = kCAEmitterLayerRectangle;
        
        objc_setAssociatedObject(self, &LayerKey, emitterLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return emitterLayer;
}

@end
