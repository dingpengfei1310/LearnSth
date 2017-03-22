//
//  AnimationView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "AnimationView.h"
#import <CoreText/CoreText.h>

@interface AnimationView ()<CAAnimationDelegate> {
    CGFloat width,height;
    CGFloat radius;
}

@property (nonatomic, strong) CAShapeLayer *baseCircleLayer;

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) CAEmitterLayer *emitterLayer;

@end

CGFloat const lineWidth = 1.0;
CGFloat const totalDuration = 3.0;

@implementation AnimationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        width = CGRectGetWidth(frame);
        height = CGRectGetHeight(frame);
        radius = width * 0.5 - 10;
        
        if (radius > 0) {
            
//            [self.layer addSublayer:self.baseCircleLayer];
            
//            [self roation];
            
//            [self strokeStart];
            
//            [self positionAnimation];
            
//            [self setGradientLayerText];
            
//            [self emitterLayerFly];
            
//            [self textWithPath];
            
//            [self drawString];
        }
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self lightSpotWithRect:rect];
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

- (void)strokeStart {
//    CABasicAnimation *strokeStart = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
//    strokeStart.repeatCount = NSIntegerMax;
//    strokeStart.duration = 2;
//    strokeStart.fromValue = @(0);
//    strokeStart.toValue = @(1.0);
//    [self.baseCircleLayer addAnimation:strokeStart forKey:@""];
    
    
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

- (void)positionAnimation {
    UIBezierPath *bezier = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, width * 0.8, 2)];
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.path = bezier.CGPath;
    lineLayer.lineWidth = 0.1;
    lineLayer.fillColor = [UIColor whiteColor].CGColor;
    lineLayer.strokeColor = [UIColor whiteColor].CGColor;
    lineLayer.bounds = CGRectMake(0, 0, width * 0.8, 2);
    lineLayer.position = CGPointMake(width * 0.5, height - 20);
    
    [self.layer addSublayer:lineLayer];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.bounds = CGRectMake(0, 0, 13.5, 13.5);
    shapeLayer.position = lineLayer.position;
    shapeLayer.contents = (id)[UIImage imageNamed:@"lightDot"].CGImage;
    [self.layer addSublayer:shapeLayer];
    
    CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
    position.repeatCount = NSIntegerMax;
    position.duration = 1.0;
    position.fromValue = [NSValue valueWithCGPoint:CGPointMake(width * 0.1, shapeLayer.position.y)];
    position.toValue = [NSValue valueWithCGPoint:CGPointMake(width * 0.8, shapeLayer.position.y)];
    [shapeLayer addAnimation:position forKey:@""];
}

- (void)setGradientLayerText {
    [self.layer addSublayer:self.gradientLayer];
    
    NSMutableArray *colors = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        UIColor *color= [self randomColor];
        [colors addObject:(id)[color CGColor]];
    }
    [self.gradientLayer setColors:colors];
    
//    UIBezierPath *bezier = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, width, 2)];
//    CAShapeLayer *layer = [CAShapeLayer layer];
//    layer.lineWidth = 0.1;
//    layer.fillColor = KBaseWhiteColor.CGColor;
//    layer.strokeColor = KBaseWhiteColor.CGColor;
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

- (void)emitterLayerFly {
    [self.layer addSublayer:self.emitterLayer];
    
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    cell.contents = (id)[UIImage imageNamed:@"lightDot"].CGImage;
    cell.birthRate = 10;
    cell.lifetime = 3;
    
    cell.velocity = 9.8;
    cell.velocityRange = 200;
    
    cell.emissionRange = M_PI * 2;
    
    cell.scale = 0.1;
    cell.scaleRange = 0.6;
    
    cell.alphaRange = 0.5;
    cell.alphaSpeed = -0.15;
    
    self.emitterLayer.emitterCells = @[cell];
}

- (void)textWithPath {
    
    CAShapeLayer *textLayer = [CAShapeLayer layer];
    textLayer.geometryFlipped = YES;
    textLayer.lineWidth = lineWidth;
    textLayer.bounds = self.bounds;
    textLayer.fillColor = [UIColor clearColor].CGColor;
    textLayer.strokeColor = [UIColor purpleColor].CGColor;
    [self.layer addSublayer:textLayer];
    textLayer.position = CGPointMake(width * 0.5, height * 0.5);
    
    
    NSString *string = @"HELLO WORLD";
    UIFont *ui_font = [UIFont systemFontOfSize:30];
    
    CTFontRef font = CTFontCreateWithName((CFStringRef)ui_font.fontName,ui_font.pointSize,NULL);
    CGMutablePathRef letters = CGPathCreateMutable();
    
    //这里设置画线的字体和大小
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)font, kCTFontAttributeName,nil];
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string
                                                                     attributes:attrs];
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    
    // for each RUN
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++) {
        // Get FONT for this run
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        // for each GLYPH in run
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++) {
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            
            {
                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
                CGPathAddPath(letters, &t, letter);
                CGPathRelease(letter);
            }
        }
    }
    
    CFRelease(font);
    CFRelease(line);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path appendPath:[UIBezierPath bezierPathWithCGPath:letters]];
    
    textLayer.path = path.CGPath;
    
    CABasicAnimation *strokeStart = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeStart.repeatCount = NSIntegerMax;
    strokeStart.duration = 3;
    strokeStart.fromValue = @(0.0);
    strokeStart.toValue = @(1.0);
    [textLayer addAnimation:strokeStart forKey:@""];
    
    CGPathRelease(letters);
}

- (void)drawString {
    //width:170
    NSString *sourthPath = [[NSBundle mainBundle] pathForResource:@"SDSloganPoints"
                                                     ofType:@"plist"];
    NSArray *pathArray = [NSArray arrayWithContentsOfFile:sourthPath];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    for (int i = 0; i < pathArray.count; i++) {
        NSArray *subArray = pathArray[i];
        
        for (int j = 0; j < subArray.count; j++) {
            if (j == 0) {
                [path moveToPoint:[self convertStringToCGPoint:subArray[j]]];
            } else {
                NSArray *pointArray = subArray[j];
                
                if (pointArray.count == 3) {
                    [path addCurveToPoint:[self convertStringToCGPoint:pointArray[0]]
                            controlPoint1:[self convertStringToCGPoint:pointArray[1]]
                            controlPoint2:[self convertStringToCGPoint:pointArray[2]]];
                    
//                    [path addLineToPoint:[self convertStringToCGPoint:pointArray[2]]];
                } else {
                    [path addLineToPoint:[self convertStringToCGPoint:pointArray[0]]];
                }
                
            }
        }
    }
    
    CAShapeLayer *textLayer = [CAShapeLayer layer];
    textLayer.lineWidth = 0.5;
    textLayer.bounds = self.bounds;
    textLayer.fillColor = [UIColor clearColor].CGColor;
    textLayer.strokeColor = [UIColor purpleColor].CGColor;
    [self.layer addSublayer:textLayer];
    textLayer.position = CGPointMake(width * 0.5, height * 0.5);
    
    textLayer.path = path.CGPath;
    
    CABasicAnimation *strokeStart = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeStart.duration = 3;
    strokeStart.fromValue = @(0.0);
    strokeStart.toValue = @(1.0);
    
    CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    colorAnimation.duration = 6.0;
    colorAnimation.timingFunction = [[CAMediaTimingFunction alloc] initWithControlPoints:0.2: 0.5: 0.5: 0.7];
    colorAnimation.fromValue = (__bridge id)([UIColor clearColor].CGColor);
    colorAnimation.toValue = (__bridge id)([UIColor purpleColor].CGColor);
    
    CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
    group.animations = @[strokeStart,colorAnimation];
    group.repeatCount = 1;
    group.duration = 6;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    [textLayer addAnimation:group forKey:@""];
}

- (CGPoint)convertStringToCGPoint:(NSString *)string {
    NSArray *points = [string componentsSeparatedByString:@","];
    return CGPointMake([points[0] floatValue], [points[1] floatValue]);
}

- (void)lightSpotWithRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat locations[] = {0.0, 1.0};
    NSArray *colors = @[(id)[UIColor greenColor].CGColor, (id)[UIColor redColor].CGColor];
    CGGradientRef gradientRef = CGGradientCreateWithColors(colorSpace, (CFArrayRef  _Nullable)colors, locations);
    
    
    CGContextSaveGState(context);
    
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradientRef, CGPointMake(0, 0), CGPointMake(50, 50), kCGGradientDrawsBeforeStartLocation);
//    CGPoint center = CGPointMake(width * 0.5, height * 0.5);
//    CGContextDrawRadialGradient(context, gradientRef, center, 0, center, height * 0.5, kCGGradientDrawsBeforeStartLocation);
    
    CGContextRestoreGState(context);
    
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradientRef);
}


#pragma mark
- (UIColor *)randomColor {
    NSInteger r = arc4random() % 255;
    NSInteger g = arc4random() % 200;
    NSInteger b = arc4random() % 100;
    
    return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1.0];
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
- (CAShapeLayer *)baseCircleLayer {
    if (!_baseCircleLayer) {
        _baseCircleLayer = [CAShapeLayer layer];
        _baseCircleLayer.lineWidth = lineWidth;
        _baseCircleLayer.bounds = self.bounds;
        _baseCircleLayer.fillColor = [UIColor clearColor].CGColor;
        _baseCircleLayer.strokeColor = [UIColor blackColor].CGColor;
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
        _gradientLayer.position = CGPointMake(width * 0.5, height * 0.5);
        [_gradientLayer setStartPoint:CGPointMake(0.0, 0.0)];
        [_gradientLayer setEndPoint:CGPointMake(1.0, 1.0)];
    }
    return _gradientLayer;
}

- (CAEmitterLayer *)emitterLayer {
    if (!_emitterLayer) {
        _emitterLayer = [CAEmitterLayer layer];
        _emitterLayer.emitterPosition = CGPointMake(width * 0.5, height * 0.5);
        _emitterLayer.emitterSize = self.frame.size;
        _emitterLayer.emitterMode = kCAEmitterLayerPoints;
    }
    return _emitterLayer;
}

@end
