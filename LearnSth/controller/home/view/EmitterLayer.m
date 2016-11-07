//
//  EmitterLayer.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/4.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "EmitterLayer.h"

@interface EmitterLayer ()

@property (nonatomic, strong) CAEmitterLayer *emitterLayer;

@end

@implementation EmitterLayer

//+ (Class)layerClass {
//    return [CAEmitterLayer class];
//}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.layer addSublayer:self.emitterLayer];
        [self setEmitterCell];
    }
    return self;
}


- (CAEmitterLayer *)emitterLayer {
    if (!_emitterLayer) {
        _emitterLayer = [CAEmitterLayer layer];
        _emitterLayer.emitterPosition = self.center;
        _emitterLayer.emitterSize = self.frame.size;
        _emitterLayer.emitterMode = kCAEmitterLayerRectangle;
    }
    return _emitterLayer;
}

- (void)setEmitterCell {
//    CAEmitterLayer *emitter = (CAEmitterLayer *)self.layer; // 修改view的layer
//    emitter.emitterPosition = self.center; // 发射粒子的位置
//    emitter.emitterSize = self.bounds.size; // 范围
//    emitter.emitterShape = kCAEmitterLayerRectangle; // 粒子形状
    
    CAEmitterCell *emitterCell = [CAEmitterCell emitterCell]; // 创建粒子
    emitterCell.contents = (id)[UIImage imageNamed:@"HUDerror"].CGImage; // 载入粒子图片
    emitterCell.birthRate = 200; // 每秒释放多少个粒子
    emitterCell.lifetime = 3.5; // 每个粒子的生命周期
    emitterCell.color = [UIColor whiteColor].CGColor; // 粒子的颜色
    emitterCell.redRange = 0.0; // RGBA设置
    emitterCell.blueRange = 0.1;
    emitterCell.greenRange = 0.0;
    emitterCell.alphaRange = 0.5;
    emitterCell.velocity = 9.8; // 重力加速度也就是物理里面G
    emitterCell.velocityRange = 350; // 加速范围
    emitterCell.emissionRange = M_PI_2; // 下落是旋转的角度
    emitterCell.emissionLongitude = -M_PI; //
    emitterCell.yAcceleration = 70; // 发射速度
    emitterCell.xAcceleration = 0;
    emitterCell.scale = 0.33;
    emitterCell.scaleRange = 1.25;
    emitterCell.scaleSpeed = -0.25;
    emitterCell.alphaRange = 0.5;
    emitterCell.alphaSpeed = -0.15;
    
    self.emitterLayer.emitterCells = @[emitterCell]; // 载入
//    emitter.emitterCells = @[emitterCell]; // 载入
}


@end
