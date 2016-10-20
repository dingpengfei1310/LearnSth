//
//  LineView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "LineView.h"

@implementation LineView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
    
    int height = CGRectGetHeight(rect);
    int count = CGRectGetWidth(rect);
    CGFloat lindWidth = CGRectGetWidth(rect) / count * 0.4;
    
//    CGContextSetLineWidth(context, CGRectGetWidth(rect) / count * 0.5);
    
//    CGContextMoveToPoint(context, 0.0, 0.0);
//    
//    for (int i = 1; i < count; i++) {
//        int pointX = 2 * i;
//        int pointY = arc4random() % height;
//        
//        CGContextAddLineToPoint(context, pointX, pointY);
//        CGContextStrokePath(context);
//        
//        CGContextMoveToPoint(context, pointX, pointY);
//    }
    
    for (int i = 0; i < count; i++) {
        int pointX = i;
        int pointY = arc4random() % height;
        
        CGPoint start = CGPointMake(pointX, 0);
        CGPoint end = CGPointMake(pointX, pointY);
        
        [self drawLineWithContext:context volumePointStart:start volumePoint:end volcolor:[UIColor greenColor] width:lindWidth];
    }
    
}

-(void)drawLineWithContext:(CGContextRef)context volumePointStart:(CGPoint)volumePointStart volumePoint:(CGPoint)volumePoint volcolor:(UIColor*)color width:(CGFloat)width{
    
    CGContextSetShouldAntialias(context, NO);
    // 设置颜色和线宽
    [color setStroke];
    
    //NSLog(@"分时页面 画线   drawVolWithContext   width = %f", width);
    CGContextSetLineWidth(context, width);
    
    //画分时量能线
    const CGPoint point[] = {volumePointStart,volumePoint};
    CGContextStrokeLineSegments(context, point, 2);
    
}

@end
