//
//  UIView+FoldPaper.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/8.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UIView+FoldPaper.h"

@implementation UIView (FoldPaper)

- (void)showFoldPaperOn:(UIView *)view {
    NSInteger folds = 3;
    CFTimeInterval duration = 2.0;
    
    CGRect selfFrame = self.frame;
    CGPoint anchorPoint;
    
    selfFrame.origin.x = self.frame.origin.x - view.bounds.size.width;
    
    anchorPoint = CGPointMake(1, 0.5);
    
    UIGraphicsBeginImageContext(selfFrame.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewSnapShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //set 3D depth
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0 / 800.0;
    CALayer *origamiLayer = [CALayer layer];
    origamiLayer.frame = self.bounds;
    origamiLayer.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1].CGColor;
    origamiLayer.sublayerTransform = transform;
    [self.layer addSublayer:origamiLayer];
    
    double startAngle;
    CGFloat frameWidth = self.bounds.size.width;
    CGFloat frameHeight = self.bounds.size.height;
    CGFloat foldWidth = frameWidth/(folds*2);
    CALayer *prevLayer = origamiLayer;
    for (int b=0; b < folds*2; b++) {
        CGRect imageFrame;
        if(b == 0)
            startAngle = -M_PI_2;
        else {
            if (b%2)
                startAngle = M_PI;
            else
                startAngle = -M_PI;
        }
        imageFrame = CGRectMake(frameWidth-(b+1)*foldWidth, 0, foldWidth, frameHeight);
        
        CATransformLayer *transLayer = [self transformLayerFromImage:viewSnapShot Frame:imageFrame Duration:duration AnchorPiont:anchorPoint StartAngle:startAngle EndAngle:0];
        [prevLayer addSublayer:transLayer];
        prevLayer = transLayer;
    }
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.frame = selfFrame;
//        [origamiLayer removeFromSuperlayer];
    }];
    
    [CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
//    CAAnimation *openAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.x" function:openFunction fromValue:self.frame.origin.x+self.frame.size.width/2 toValue:selfFrame.origin.x+self.frame.size.width/2];
    
    CAAnimation *openAnimation = [self animationWithKeyPath:@"position.x" fromValue:self.frame.origin.x+self.frame.size.width/2 toValue:selfFrame.origin.x+self.frame.size.width/2];
    openAnimation.fillMode = kCAFillModeForwards;
    [openAnimation setRemovedOnCompletion:NO];
    [self.layer addAnimation:openAnimation forKey:@"position"];
    [CATransaction commit];
}

#pragma mark
- (CATransformLayer *)transformLayerFromImage:(UIImage *)image Frame:(CGRect)frame Duration:(CGFloat)duration AnchorPiont:(CGPoint)anchorPoint StartAngle:(double)start EndAngle:(double)end;
{
    CATransformLayer *jointLayer = [CATransformLayer layer];
    jointLayer.anchorPoint = anchorPoint;
    CGFloat layerWidth;
    layerWidth = frame.origin.x + frame.size.width;
    jointLayer.frame = CGRectMake(0, 0, layerWidth, frame.size.height);
    jointLayer.position = CGPointMake(layerWidth, frame.size.height/2);
    
    //map image onto transform layer
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    imageLayer.anchorPoint = anchorPoint;
    imageLayer.position = CGPointMake(layerWidth*anchorPoint.x, frame.size.height/2);
    [jointLayer addSublayer:imageLayer];
    CGImageRef imageCrop = CGImageCreateWithImageInRect(image.CGImage, frame);
    imageLayer.contents = (__bridge id)imageCrop;
    imageLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    //add shadow
    NSInteger index = frame.origin.x/frame.size.width;
    double shadowAniOpacity;
    CAGradientLayer *shadowLayer = [CAGradientLayer layer];
    shadowLayer.frame = imageLayer.bounds;
    shadowLayer.backgroundColor = [UIColor darkGrayColor].CGColor;
    shadowLayer.opacity = 0.0;
    shadowLayer.colors = [NSArray arrayWithObjects:(id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor, nil];
    if (index%2) {
        shadowLayer.startPoint = CGPointMake(0, 0.5);
        shadowLayer.endPoint = CGPointMake(1, 0.5);
        shadowAniOpacity = (anchorPoint.x)?0.24:0.32;
    }
    else {
        shadowLayer.startPoint = CGPointMake(1, 0.5);
        shadowLayer.endPoint = CGPointMake(0, 0.5);
        shadowAniOpacity = (anchorPoint.x)?0.32:0.24;
    }
    [imageLayer addSublayer:shadowLayer];
    
    //animate open/close animation
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    [animation setDuration:duration];
    [animation setFromValue:[NSNumber numberWithDouble:start]];
    [animation setToValue:[NSNumber numberWithDouble:end]];
    [animation setRemovedOnCompletion:NO];
    [jointLayer addAnimation:animation forKey:@"jointAnimation"];
    
    //animate shadow opacity
    animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [animation setDuration:duration];
    [animation setFromValue:[NSNumber numberWithDouble:(start)?shadowAniOpacity:0]];
    [animation setToValue:[NSNumber numberWithDouble:(start)?0:shadowAniOpacity]];
    [animation setRemovedOnCompletion:NO];
    [shadowLayer addAnimation:animation forKey:nil];
    
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
