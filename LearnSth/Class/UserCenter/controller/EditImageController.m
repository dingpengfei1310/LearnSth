//
//  EditImageController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/8/15.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "EditImageController.h"

@interface EditImageController ()<UIScrollViewDelegate> {
    CGFloat circleW;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation EditImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"移动与缩放";
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finish:)];
    
    [self initSubView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self navigationBarColorClear];
}

- (void)initSubView {
    CGFloat viewW = [UIScreen mainScreen].bounds.size.width;
    CGFloat viewH = [UIScreen mainScreen].bounds.size.height;
    circleW = viewW * 0.8;
    
    CGRect circleRect = CGRectMake((viewW - circleW) * 0.5, (viewH - circleW) * 0.5, circleW, circleW);
    
    //
    _scrollView = [[UIScrollView alloc] initWithFrame:circleRect];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.clipsToBounds = NO;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    //
    _imageView = [[UIImageView alloc] init];
    _imageView.image = _originalImage;
    [_scrollView addSubview:_imageView];
    
    CGFloat imageW = _originalImage.size.width;
    CGFloat imageH = _originalImage.size.height;
    CGFloat imageScale = imageW / imageH;
    
    imageW = viewW;//默认，宽度充满
    imageH = imageW / imageScale;
    if (imageH < circleW) {
        imageH = circleW;
        imageW = imageH * imageScale;
    }
    _imageView.bounds = CGRectMake(0, 0, imageW, imageH);
    _imageView.center = CGPointMake(imageW * 0.5, imageH * 0.5);
    
    _scrollView.contentSize = CGSizeMake(imageW, imageH);
    _scrollView.contentOffset = CGPointMake((imageW - circleW) * 0.5, (imageH - circleW) * 0.5);
    _scrollView.maximumZoomScale = 1.5;
    _scrollView.minimumZoomScale = circleW / MIN(imageW, imageH);
    
    [self.view addGestureRecognizer:_scrollView.panGestureRecognizer];
    [self.view addGestureRecognizer:_scrollView.pinchGestureRecognizer];
    
    //
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    [maskPath appendPath:[[UIBezierPath bezierPathWithRoundedRect:circleRect cornerRadius:circleW * 0.5] bezierPathByReversingPath]];
    maskLayer.path = maskPath.CGPath;
    
    UIView *maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    maskView.userInteractionEnabled = NO;
    maskView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    maskView.layer.mask = maskLayer;
    [self.view addSubview:maskView];
}

#pragma mark
- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)finish:(UIBarButtonItem *)item {
    CGSize size = _scrollView.contentSize;
    CGPoint point = _scrollView.contentOffset;
    
    CGFloat imageRefWidth =  CGImageGetWidth(_originalImage.CGImage);
    CGFloat imageRefHeight =  CGImageGetWidth(_originalImage.CGImage);
    CGRect rect =  CGRectMake(point.x / size.width * imageRefWidth,
                              point.y / size.height * imageRefHeight,
                              circleW / size.width * imageRefWidth,
                              circleW / size.width * imageRefWidth);
    CGImageRef imageRef = CGImageCreateWithImageInRect(_originalImage.CGImage, rect);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(circleW, circleW), NO, 0);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, circleW, circleW) cornerRadius:circleW * 0.5];
    [bezierPath addClip];
    [[UIImage imageWithCGImage:imageRef] drawInRect:CGRectMake(0, 0, circleW, circleW)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(imageRef);
    
    [self cancel];
    if (self.FinishImageBlock) {
        self.FinishImageBlock(image);
    }
}

#pragma mark
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
