//
//  FoldView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/18.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "FoldPaperView.h"

@interface FoldPaperView ()

@property (nonatomic, strong) UIImage *currentImage;
@property (nonatomic, strong) UIImageView *centerImageView;

@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *rightImageView;

@property (nonatomic, assign) NSUInteger initialLocation;

@end

@implementation FoldPaperView {
    CGFloat width,height;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        width = frame.size.width;
        height = frame.size.height;
        self.currentImage = [UIImage imageNamed:@"panda"];
        
        [self addImageViews];
    }
    return self;
}

- (void)addImageViews {
    NSInteger count = 6;
    
    for (int i = 0; i < count; i++) {
        CGRect rect = CGRectMake(0, i * height / count, width, height / count);
        UIImageView *imageView = [[UIImageView alloc] init];
        if (i % 2 == 0) {
            imageView.layer.anchorPoint = CGPointMake(0.5, 0);
        } else {
            imageView.layer.anchorPoint = CGPointMake(0.5, 1);
        }
        imageView.frame = rect;
        imageView.image = [self clipImageWithImage:self.currentImage
                                        totalCount:count
                                           ofIndex:i];
        [self addSubview:imageView];
    }
    
}


- (void)foldPaperWith:(CGFloat)scale {
    
    for (int i = 0; i < self.subviews.count; i++) {
        UIImageView *imageView = self.subviews[i];
        
        CATransform3D rotateTransform = CATransform3DIdentity;
        rotateTransform.m34 = -2.0 / 1000.0;
        rotateTransform = CATransform3DRotate(rotateTransform, -scale, 1, 0, 0);
        
        CATransform3D translationTransform = CATransform3DMakeTranslation(0, - sin(scale * 0.5) * height * 0.5, 0);
        
//        NSLog(@"%@",[NSValue valueWithCGRect:self.centerImageView.frame]);
        
        
        if (i % 2 == 0) {
            translationTransform = CATransform3DIdentity;
            rotateTransform.m34 = -2.0 / 1000.0;
        } else {
//            translationTransform = CATransform3DIdentity;
            translationTransform = CATransform3DMakeTranslation(0, - sin(scale * 0.5) * height * 0.5, 0);
            rotateTransform.m34 = 2.0 / 1000.0;
        }
        
        CATransform3D transform = CATransform3DConcat(rotateTransform, translationTransform);
        imageView.layer.sublayerTransform = transform;
    }
}

#pragma mark
-(void)panHandle:(UIPanGestureRecognizer *)pan{
    
    CGPoint location = [pan locationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.initialLocation = location.x;
    }
//    NSLog(@"y:%@",[self.rightImageView.layer valueForKeyPath:@"transform.rotation.y"]);
//    NSLog(@"x:%@",[self.rightImageView.layer valueForKeyPath:@"transform.rotation.x"]);
    
    CGFloat conversioFactor = M_PI/(CGRectGetWidth(self.bounds)-self.initialLocation);
    self.rightImageView.layer.transform = [self getTransForm3DWithAngle:(location.x-self.initialLocation)*conversioFactor];
}

- (UIImage *)clipImageWithImage:(UIImage * )image isLeftImage:(BOOL)isLeft {
    if (!image) return nil;
    
    CGFloat imageWidth = CGImageGetWidth(image.CGImage);
    CGFloat imageHeight = CGImageGetHeight(image.CGImage);
    
    CGRect imageRect = CGRectMake(0, 0, imageWidth / 2, imageHeight);
    if (!isLeft) {
        imageRect.origin.x = imageWidth / 2;
    }
    CGImageRef imgRef = CGImageCreateWithImageInRect(image.CGImage, imageRect);
    UIImage *clipImage = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    
    return clipImage;
}

- (UIImage *)clipImageWithImage:(UIImage *)image totalCount:(NSInteger)count ofIndex:(NSInteger)index {
    CGFloat imageWidth = CGImageGetWidth(image.CGImage);
    CGFloat imageHeight = CGImageGetHeight(image.CGImage);
    
    CGRect imageRect = CGRectMake(0, imageHeight / count * index, imageWidth, imageHeight / count);
    
    CGImageRef imgRef = CGImageCreateWithImageInRect(image.CGImage, imageRect);
    UIImage *clipImage = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    
    return clipImage;
}

- (CATransform3D)getTransForm3DWithAngle:(CGFloat)angle {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 4.5/-2000;
    transform = CATransform3DRotate(transform,angle, 0, 1, 0);
    return transform;
}

//- (void)fold:(CGFloat)fraction {
//    
//    
//    
//    float delta = asinf(fraction);
//    
//    [self.layer setTransform:CATransform3DMakeRotation((M_PI / 2) - delta, 1, 0, 0)];
//    
//    // rotate topView on the right edge of the view
//    // translate rotated view to the bottom to join to the edge of the bottomView
////    CATransform3D transform1 = CATransform3DMakeTranslation(0, -2*self.bottomView.frame.size.height, 0);
////    CATransform3D transform2 = CATransform3DMakeRotation((M_PI / 2) - delta, -1, 0, 0);
////    CATransform3D transform = CATransform3DConcat(transform2, transform1);
////    [self.topView.layer setTransform:transform];
//    
//}


#pragma mark
- (UIImageView *)leftImageView {
    if (!_leftImageView) {
        _leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width * 0.5, height)];
        _leftImageView.userInteractionEnabled = YES;
        _leftImageView.image = [self clipImageWithImage:self.currentImage
                                            isLeftImage:YES];
    }
    
    return _leftImageView;
}

- (UIImageView *)rightImageView {
    if (!_rightImageView) {
        _rightImageView = [[UIImageView alloc] init];
        _rightImageView.userInteractionEnabled = YES;
        _rightImageView.layer.anchorPoint = CGPointMake(0,0.5);
        _rightImageView.frame = CGRectMake(width * 0.5, 0, width * 0.5, height);
        _rightImageView.image = [self clipImageWithImage:self.currentImage
                                            isLeftImage:NO];
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panHandle:)];
        [self.rightImageView addGestureRecognizer:pan];
    }
    
    return _rightImageView;
}

- (UIImageView *)centerImageView {
    if (!_centerImageView) {
        _centerImageView = [[UIImageView alloc] init];
        _centerImageView.frame = CGRectMake(0, 0, width, height);
        _centerImageView.image = self.currentImage;
    }
    
    return _centerImageView;
}

@end
