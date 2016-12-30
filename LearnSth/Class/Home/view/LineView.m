//
//  LineView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "LineView.h"

@implementation LineView {
    CGFloat width,height;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        width = CGRectGetWidth(frame);
        height = CGRectGetHeight(frame);
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
//    [self drawLine];
    [self drawCurve];
}

#pragma mark
- (void)drawLine {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat lineWidth = 10;
    
    for (int i = 0; i < 30; i++) {
        int pointX = i * lineWidth;
        int pointY = arc4random() % 100 + 10;
        
        CGPoint start = CGPointMake(pointX, 0);
        CGPoint end = CGPointMake(pointX, pointY);
        
        [[UIColor greenColor] set];
        CGContextSetLineWidth(context, lineWidth * 0.8);
        
        const CGPoint point[] = {start,end};
        CGContextStrokeLineSegments(context, point, 2);
    }
}

- (void)drawCurve {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, 10, 10);
    CGContextAddLineToPoint(context, 15, 30);
    
    CGContextAddCurveToPoint(context, 40, 40, 100, 10, 200, 200);
    
//    CGFloat lengths[] = {5,2};
//    CGContextSetLineDash(context, 0, lengths, 2);//
    
    [[UIColor greenColor] set];
    CGContextStrokePath(context);
    
}

@end
