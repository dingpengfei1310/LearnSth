//
//  UIView+FoldPaper.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/8.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UIView+FoldPaper.h"

@implementation UIView (FoldPaper)

- (void)showFoldPaperWithFolds:(NSInteger)folds duration:(CGFloat)duration {
    if (!self.superview) {
        return;
    }
    CGRect frame = self.frame;
    
    UIGraphicsBeginImageContextWithOptions(frame.size, YES, 2);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewSnapShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGPoint anchorPoint = CGPointMake(1.0, 0.5);
    UIView *foldView = [[UIView alloc] initWithFrame:frame];
    [self.superview addSubview:foldView];
    
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -3.0 / 1000.0;
    CALayer *foldLayer = [CALayer layer];
    foldLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);;
    foldLayer.sublayerTransform = transform;
    [foldView.layer addSublayer:foldLayer];
    
    CGFloat startAngle;
    for (int i = 0; i < folds * 2; i++) {
        if(i == 0) {
            startAngle = - M_PI_2;
        } else {
            if (i % 2)
                startAngle = M_PI;
            else
                startAngle = - M_PI;
        }
        
        CATransformLayer *transLayer = [self layerFromImage:viewSnapShot index:i count:folds * 2 anchorPiont:anchorPoint startAngle:startAngle];
        [foldLayer addSublayer:transLayer];
        foldLayer = transLayer;
    }
    
    CAAnimation *openAnimation = [self animationWithKeyPath:@"position.x" fromValue:self.frame.size.width toValue:self.frame.size.width * 0.5];
    openAnimation.fillMode = kCAFillModeForwards;
    openAnimation.duration = duration;
    [openAnimation setRemovedOnCompletion:NO];
    [foldView.layer addAnimation:openAnimation forKey:@"position"];
    
    self.hidden = YES;
    self.frame = CGRectMake(frame.size.width, frame.origin.y, 0, frame.size.height);
    [UIView animateWithDuration:duration animations:^{
        self.frame = frame;
    } completion:^(BOOL finished) {
        [foldView removeFromSuperview];
        self.hidden = NO;
    }];
}

- (CATransformLayer *)layerFromImage:(UIImage *)image index:(NSInteger)index count:(NSInteger)count anchorPiont:(CGPoint)anchorPoint startAngle:(CGFloat)startAngle {
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat foldWidth = width / count;
    CGRect frame = CGRectMake(0, 0, width -  index * foldWidth, height);
    
    CATransformLayer *jointLayer = [CATransformLayer layer];
    jointLayer.anchorPoint = anchorPoint;
    jointLayer.frame = frame;
    jointLayer.position = CGPointMake(width -  index * foldWidth, height * 0.5);
    
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, foldWidth, height);
    imageLayer.anchorPoint = anchorPoint;
    imageLayer.position = CGPointMake(width -  index * foldWidth, height * 0.5);
    [jointLayer addSublayer:imageLayer];
    
    CGRect rect = CGRectMake(CGImageGetWidth(image.CGImage) / count * (count - index - 1), 0, CGImageGetWidth(image.CGImage) / count, CGImageGetHeight(image.CGImage));
    CGImageRef imageCrop = CGImageCreateWithImageInRect(image.CGImage, rect);
    imageLayer.contents = (__bridge id)imageCrop;
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    [animation setDuration:2.0];
    [animation setFromValue:[NSNumber numberWithDouble:startAngle]];
    [animation setToValue:[NSNumber numberWithDouble:0]];
    [animation setRemovedOnCompletion:NO];
    [jointLayer addAnimation:animation forKey:@"jointAnimation"];
    
    CGImageRelease(imageCrop);
    
    return jointLayer;
}

- (CAKeyframeAnimation *)animationWithKeyPath:(NSString *)path fromValue:(double)fromValue toValue:(double)toValue
{
    // get a keyframe animation to set up
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:path];
    // break the time into steps (the more steps, the smoother the animation)
    NSUInteger steps = 100;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:steps];
    double time = 0.0;
    double timeStep = 1.0 / (double)(steps - 1);
    for(NSUInteger i = 0; i < steps; i++) {
        double value = fromValue + ([self openFunction:time] * (toValue - fromValue));
        [values addObject:[NSNumber numberWithDouble:value]];
        time += timeStep;
    }
    // we want linear animation between keyframes, with equal time steps
    animation.calculationMode = kCAAnimationLinear;
    // set keyframes and we're done
    [animation setValues:values];
    return animation;
}

- (double)openFunction:(double)time {
    return sin(time*M_PI_2);
}

@end

