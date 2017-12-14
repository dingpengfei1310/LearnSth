//
//  HandDrawView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/6/22.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "HandDrawView.h"
#import "UIImage+Tool.h"

@interface HandDrawView()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIBezierPath *bezierPath;

@end

@implementation HandDrawView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _lineWidth = 10.0;
        _bezierPath = [UIBezierPath bezierPath];
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageView];
        
        self.forekgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
}

- (void)setForekgroundColor:(UIColor *)forekgroundColor {
    _forekgroundColor = forekgroundColor;
    _imageView.image = [UIImage imageWithColor:_forekgroundColor];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [touches.anyObject locationInView:_imageView];
    if (touches.allObjects.count == 1) {
        [_bezierPath moveToPoint:point];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [touches.anyObject locationInView:_imageView];
    if (touches.allObjects.count == 1) {
        [_bezierPath addLineToPoint:point];
        
        UIGraphicsBeginImageContextWithOptions(_imageView.bounds.size, NO, 1);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [self.imageView.layer renderInContext:ctx];
        
        //    CGContextSetBlendMode(ctx, kCGBlendModeCopy);
        CGContextSetBlendMode(ctx, kCGBlendModeDestinationIn);
        CGContextSetStrokeColorWithColor(ctx, [UIColor clearColor].CGColor);
        CGContextSetLineWidth(ctx, _lineWidth);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        
        CGContextAddPath(ctx, _bezierPath.CGPath);
        CGContextStrokePath(ctx);
        
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.imageView.image = newImage;
    }
}

@end
