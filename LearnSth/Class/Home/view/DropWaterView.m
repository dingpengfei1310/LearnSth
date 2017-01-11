//
//  DropWaterView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/1/10.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "DropWaterView.h"


@interface DropWaterView () <UICollisionBehaviorDelegate> {
    CGFloat width;
    CGFloat height;
    UIColor *backgroundColor;
}

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, strong) UIView *waterFallView;
@property (nonatomic, strong) UIView *waterTempView;

@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;

@property (nonatomic, strong) CADisplayLink *waterFallDispalyLink;
@property (nonatomic, strong) CADisplayLink *waterBackDispalyLink;

@end

const CGFloat topWidth = 4;
const CGFloat raindropRadius = 5;

@implementation DropWaterView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        width = frame.size.width;
        height = frame.size.height;
        backgroundColor = [UIColor orangeColor];
        self.clipsToBounds = YES;
        
        [self.layer addSublayer:self.shapeLayer];
        [self addSubview:self.waterTempView];
        [self addSubview:self.waterFallView];
    }
    return self;
}

- (void)raindropBeginFall {
    self.waterFallView.alpha = 1.0;
    self.waterFallView.backgroundColor = backgroundColor;
    self.waterFallView.center = CGPointMake(width * 0.5, -raindropRadius);
    [self setupBehavior];
    
    [self.waterFallDispalyLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self.waterBackDispalyLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.waterFallDispalyLink.paused = NO;
    self.waterBackDispalyLink.paused = YES;
}

- (void)setupBehavior {
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.waterFallView]];
    [self.dynamicAnimator addBehavior:gravityBehavior];
    
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.waterFallView]];
        collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
    //    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    collisionBehavior.collisionDelegate = self;
    [collisionBehavior addBoundaryWithIdentifier:@"floor"
                                       fromPoint:CGPointMake(0, height)
                                         toPoint:CGPointMake(width, height)];
    [self.dynamicAnimator addBehavior:collisionBehavior];
    
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.waterFallView]];
    itemBehavior.elasticity = 0.75;//弹性0.0-1.0
    [self.dynamicAnimator addBehavior:itemBehavior];
    
//    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.waterFallView]
//                                                                    mode:UIPushBehaviorModeInstantaneous];
//    pushBehavior.angle = M_PI_4;
//    pushBehavior.magnitude = 0.75;
//    [self.dynamicAnimator addBehavior:pushBehavior];
}

- (void)reloadWaterFallPath {
    CGFloat y2 = self.waterFallView.center.y;
    
    if (y2 > raindropRadius) {
        [self.waterFallDispalyLink invalidate];
        self.waterFallDispalyLink = nil;
        
        self.waterTempView.center = CGPointMake(width * 0.5, y2);
        [UIView animateWithDuration:0.5 animations:^{
            self.waterTempView.center = CGPointMake(width * 0.5, -raindropRadius);
        }];
        self.waterBackDispalyLink.paused = NO;
        return;
    }
    
    UIBezierPath *bezierPath = [self createBezierPathWithStart:CGPointMake(width * 0.5, 0)
                                                        radius:topWidth * 2
                                                           end:CGPointMake(width * 0.5, y2)
                                                        radius:raindropRadius];
    self.shapeLayer.path = bezierPath.CGPath;
}

- (void)reloadWaterBackPath  {
    CGPoint assistancePoint = [[self.waterTempView.layer.presentationLayer valueForKey:@"position"] CGPointValue];
    CGFloat y2 = assistancePoint.y;
    
    if (y2 <= -raindropRadius) {
        [self.waterBackDispalyLink invalidate];
        self.waterBackDispalyLink = nil;
        self.shapeLayer.path = nil;
        return;
    }
    
    UIBezierPath *bezierPath = [self createBezierPathWithStart:CGPointMake(width * 0.5, 0)
                                                        radius:topWidth * 2
                                                           end:CGPointMake(width * 0.5, y2)
                                                        radius:raindropRadius];
    [bezierPath addArcWithCenter:assistancePoint radius:raindropRadius startAngle:0 endAngle:M_PI clockwise:YES];
    
    self.shapeLayer.path = bezierPath.CGPath;
}


- (UIBezierPath *)createBezierPathWithStart:(CGPoint)start radius:(CGFloat)startRadius end:(CGPoint)end radius:(CGFloat)endRadius {
    if (startRadius > endRadius) {
        CGPoint tempPoint = start;
        start = end;
        end = tempPoint;
        
        CGFloat tempR = startRadius;
        startRadius = endRadius;
        endRadius = tempR;
    }
    
    CGFloat r1 = startRadius;
    CGFloat r2 = endRadius;
    
    CGFloat x1 = start.x;
    CGFloat y1 = start.y;
    CGFloat x2 = end.x;
    CGFloat y2 = end.y;
    
    CGFloat distance = sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
    CGFloat sinDegree = (x2 - x1) / distance;
    CGFloat cosDegree = (y2 - y1) / distance;
    
    CGPoint pointA = CGPointMake(x1 - r1 * cosDegree, y1 + r1 * sinDegree);
    CGPoint pointB = CGPointMake(x1 + r1 * cosDegree, y1 - r1 * sinDegree);
    CGPoint pointC = CGPointMake(x2 + r2 * cosDegree, y2 - r2 * sinDegree);
    CGPoint pointD = CGPointMake(x2 - r2 * cosDegree, y2 + r2 * sinDegree);
    CGPoint pointN = CGPointMake(pointB.x + (distance / 2) * sinDegree, pointB.y + (distance / 2) * cosDegree);
    CGPoint pointM = CGPointMake(pointA.x + (distance / 2) * sinDegree, pointA.y + (distance / 2) * cosDegree);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pointA];
    [path addLineToPoint:pointB];
    [path addQuadCurveToPoint:pointC controlPoint:pointN];
    [path addLineToPoint:pointD];
    [path addQuadCurveToPoint:pointA controlPoint:pointM];
    
    return path;
}

#pragma mark
- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p {
    self.waterFallView.backgroundColor = [UIColor colorWithRed:arc4random() % 255 / 255.0
                                                         green:arc4random() % 255 / 255.0
                                                          blue:arc4random() % 255 / 255.0
                                                         alpha:1.0];
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier {
    if (item.center.y >= height - raindropRadius * 2) {
        self.waterFallView.alpha = 0.0;
    }
}

#pragma mark
- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = backgroundColor.CGColor;
        _shapeLayer.strokeColor = [UIColor clearColor].CGColor;
    }
    return _shapeLayer;
}

- (UIView *)waterFallView {
    if (!_waterFallView) {
        _waterFallView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, raindropRadius * 2, raindropRadius * 2)];
        _waterFallView.center = CGPointMake(width * 0.4, -raindropRadius);
        _waterFallView.layer.cornerRadius = raindropRadius;
        _waterFallView.backgroundColor = backgroundColor;
    }
    return _waterFallView;
}

- (UIView *)waterTempView {
    if (!_waterTempView) {
        _waterTempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, raindropRadius * 2, raindropRadius * 2)];
        _waterTempView.center = CGPointMake(width * 0.5, -raindropRadius);
        _waterTempView.layer.cornerRadius = raindropRadius;
        _waterTempView.backgroundColor = [UIColor clearColor];
    }
    return _waterTempView;
}

- (CADisplayLink *)waterFallDispalyLink {
    if (!_waterFallDispalyLink) {
        _waterFallDispalyLink = [CADisplayLink displayLinkWithTarget:self
                                                   selector:@selector(reloadWaterFallPath)];
        _waterFallDispalyLink.frameInterval = 2.0;
        _waterFallDispalyLink.paused = YES;
    }
    return _waterFallDispalyLink;
}

- (CADisplayLink *)waterBackDispalyLink {
    if (!_waterBackDispalyLink) {
        _waterBackDispalyLink = [CADisplayLink displayLinkWithTarget:self
                                                            selector:@selector(reloadWaterBackPath)];
        _waterBackDispalyLink.frameInterval = 2.0;
        _waterBackDispalyLink.paused = YES;
    }
    return _waterBackDispalyLink;
}

@end

