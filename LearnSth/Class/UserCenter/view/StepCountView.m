//
//  StepCountView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/5/12.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "StepCountView.h"

@interface StepCountView ()<UIScrollViewDelegate>

@property (nonatomic, assign) CGFloat viewW;
@property (nonatomic, assign) CGFloat viewH;

@property (nonatomic, strong) CAShapeLayer *lineLayer;
@property (nonatomic, strong) NSMutableArray *lineArray;
@property (nonatomic, strong) NSMutableArray *displayArray;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) BOOL isFillColor;

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) CAShapeLayer *xLayer;
@property (nonatomic, strong) CAShapeLayer *yLayer;

@property (nonatomic, assign) CGFloat minScaleX;
@property (nonatomic, assign) CGFloat maxScaleX;

@end

@implementation StepCountView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _viewW = CGRectGetWidth(frame);
        _viewH = CGRectGetHeight(frame);
        
        [self initConfig];
        [self initSubView];
    }
    return self;
}

- (void)initConfig {
    self.topMargin = 10;
    self.leftMargin = 10;
    self.bottomMargin = 10;
    self.rightMargin = 10;
    
    self.scaleX = 6.0;
    self.scaleY = 1.0;
    
    self.lineWidth = 1.0;
    self.lineColor = KBaseBlueColor;
    self.fillColor = KBaseTextColor;
    //self.isFillColor = YES;
    
    self.minScaleX = 2.0;
    self.maxScaleX = 1.0;
}

- (void)initSubView {
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _viewW, _viewH)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    [_scrollView addGestureRecognizer:longPress];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [_scrollView addGestureRecognizer:pinch];
    
    [self.scrollView.layer addSublayer:self.lineLayer];
    
    [self.scrollView.layer addSublayer:self.xLayer];
    [self.scrollView.layer addSublayer:self.yLayer];
    
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _viewW, 20)];
    _textLabel.font = [UIFont boldSystemFontOfSize:13];
    _textLabel.hidden = YES;
    [self addSubview:_textLabel];
}

#pragma mark
- (void)setDataArray:(NSArray *)dataArray {
    if (dataArray.count == 0) {
        return;
    }
    _dataArray = dataArray;
    
    NSNumber *min  = [_dataArray valueForKeyPath:@"@min.floatValue"];
    NSNumber *max = [_dataArray valueForKeyPath:@"@max.floatValue"];
    self.maxY = [max floatValue];
    self.minY  = [min floatValue];
    self.scaleY = (_viewH - self.topMargin - self.bottomMargin) / (self.maxY - self.minY);
    
    [self handleData];
    [self drawLineLayer];
}

- (void)handleData {
    _lineArray = [NSMutableArray array];
    [_dataArray enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        CGFloat yPostion = (self.maxY - [obj floatValue]) * self.scaleY + self.topMargin;
        [_lineArray addObject:@(yPostion)];
    }];
    
    _scrollView.contentSize = CGSizeMake(_viewW, 0);
    CGFloat sizeW = self.scaleX * (_lineArray.count - 1) + self.leftMargin + self.rightMargin;
    if (sizeW >= _viewW) {
        _scrollView.contentSize = CGSizeMake(sizeW, 0);
    } else {
        self.scaleX = (_viewW - self.leftMargin - self.rightMargin) / (_dataArray.count - 1);
    }
}

#pragma mark
- (void)pinchGesture:(UIPinchGestureRecognizer *)pinch {
    if (pinch.numberOfTouches < 2) {
        return;
    }
    
    if (pinch.state == UIGestureRecognizerStateBegan) {
    } else if (pinch.state == UIGestureRecognizerStateChanged) {
        CGFloat diffScale = pinch.scale - 1.0;
        
        if (fabs(diffScale) > 0.1) {
            self.scaleX = self.scaleX * (1 + diffScale * 0.1);
            self.scaleX = MAX(_minScaleX, MIN(_maxScaleX, self.scaleX));
            
            [self handleData];
            [self drawLineLayer];
        }
    }
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan || longPress.state == UIGestureRecognizerStateChanged) {
        CGPoint location = [longPress locationInView:self.scrollView];
        if (location.x < self.leftMargin || location.x > (_scrollView.contentSize.width - self.leftMargin)) {
            return;
        }
        
        NSInteger index = (location.x - self.leftMargin) / self.scaleX;
        CGFloat lastX = self.leftMargin + (index - 1) * self.scaleX;
        CGFloat nextX = self.leftMargin + (index + 1) * self.scaleX;
        if (location.x  - lastX > nextX - location.x) {
            index = index + 1;
        }
        
        CGFloat currentX = self.leftMargin + index * self.scaleX;
        CGFloat currentY = [self.lineArray[index] floatValue];
        
        [self drawXYLayerWithx:currentX y:currentY];
        
        _textLabel.frame = CGRectMake(0, currentY - 10, 50, 20);
        _textLabel.hidden = NO;
        _textLabel.text = [NSString stringWithFormat:@"%@",self.dataArray[index]];
        
    } else if (longPress.state == UIGestureRecognizerStateEnded) {
        self.xLayer.path = [UIBezierPath bezierPath].CGPath;
        self.yLayer.path = [UIBezierPath bezierPath].CGPath;
        _textLabel.hidden = YES;
    }
}

- (void)drawXYLayerWithx:(CGFloat)x y:(CGFloat)y {
    UIBezierPath *xPath = [UIBezierPath bezierPath];
    //    [xPath moveToPoint:CGPointMake(x, y)];
    [xPath moveToPoint:CGPointMake(x, self.topMargin)];
    [xPath addLineToPoint:CGPointMake(x, _viewH - self.bottomMargin)];
    self.xLayer.path = xPath.CGPath;
    
    UIBezierPath *yPath = [UIBezierPath bezierPath];
    [yPath moveToPoint:CGPointMake(self.leftMargin, y)];
    [yPath addLineToPoint:CGPointMake(_scrollView.contentSize.width - self.rightMargin, y)];
    //    [yPath addLineToPoint:CGPointMake(x, y)];
    self.yLayer.path = yPath.CGPath;
}

#pragma mark
- (void)drawLineLayer {
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [self.lineArray enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            [bezierPath moveToPoint:CGPointMake(self.scaleX * idx + self.leftMargin,obj.floatValue)];
        } else {
            [bezierPath addLineToPoint:CGPointMake(self.scaleX * idx + self.leftMargin,obj.floatValue)];
        }
    }];
    
    if (self.isFillColor) {
        self.lineLayer.fillColor = self.fillColor.CGColor;
        self.lineLayer.lineWidth = 0;
        
        [bezierPath addLineToPoint:CGPointMake(_scrollView.contentSize.width - self.leftMargin ,_viewH - self.bottomMargin)];
        [bezierPath addLineToPoint:CGPointMake(self.leftMargin ,_viewH - self.bottomMargin)];
    }
    self.lineLayer.path = bezierPath.CGPath;
    
//    [self startAnimation];
}

- (void)startAnimation {
    CABasicAnimation*pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 2.0f;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.fromValue = @0.0f;
    pathAnimation.toValue = @(1);
    [self.lineLayer addAnimation:pathAnimation forKey:nil];
}

#pragma mark
- (CAShapeLayer *)lineLayer {
    if (!_lineLayer) {
        _lineLayer = [CAShapeLayer layer];
        _lineLayer.lineCap = kCALineCapRound;
        _lineLayer.lineJoin = kCALineJoinRound;
        
        _lineLayer.contentsScale = [UIScreen mainScreen].scale;
        _lineLayer.lineWidth = self.lineWidth;
        
        _lineLayer.strokeColor = self.lineColor.CGColor;
        _lineLayer.fillColor = [[UIColor clearColor] CGColor];
    }
    return _lineLayer;
}

- (CAShapeLayer *)xLayer {
    if (!_xLayer) {
        _xLayer = [CAShapeLayer layer];
        _xLayer.lineCap = kCALineCapRound;
        _xLayer.lineJoin = kCALineJoinRound;
        
        _xLayer.contentsScale = [UIScreen mainScreen].scale;
        _xLayer.lineWidth = self.lineWidth;
        
        _xLayer.strokeColor = self.fillColor.CGColor;
        _xLayer.fillColor = [[UIColor clearColor] CGColor];
    }
    return _xLayer;
}

- (CAShapeLayer *)yLayer {
    if (!_yLayer) {
        _yLayer = [CAShapeLayer layer];
        _yLayer.lineCap = kCALineCapRound;
        _yLayer.lineJoin = kCALineJoinRound;
        
        _yLayer.contentsScale = [UIScreen mainScreen].scale;
        _yLayer.lineWidth = self.lineWidth;
        
        _yLayer.strokeColor = self.fillColor.CGColor;
        _yLayer.fillColor = [[UIColor clearColor] CGColor];
    }
    return _yLayer;
}

@end
