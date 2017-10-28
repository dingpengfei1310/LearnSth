//
//  ShowViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/7/24.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "ShowViewController.h"

#import "BaseConfigure.h"
#import "UIColor+Tool.h"
#import "UIImage+Tool.h"

@interface ShowViewController () <UIScrollViewDelegate>{
    CGFloat viewW;
    CGFloat viewH;
}

@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation ShowViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    viewW = self.view.frame.size.width;
    viewH = self.view.frame.size.height;
    NSInteger pageCount = 2;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, viewW, viewH)];
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(viewW * pageCount, 0);
    scrollView.pagingEnabled = YES;
    [self.view addSubview:scrollView];
    
    CGFloat leftM = 80;
    UIButton *startButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewW - leftM * 2, 38)];
    startButton.center = CGPointMake(viewW * (pageCount - 1) + viewW * 0.5, viewH * 0.9 - 10);
    UIImage *image = [UIImage imageWithColor:KBaseAppColor];
    UIImage *cornerImage = [image cornerImageWithSize:CGSizeMake(viewW - leftM * 2, 38) radius:3];
    [startButton setBackgroundImage:cornerImage forState:UIControlStateNormal];
    [startButton setTitle:@"开始体验" forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:startButton];
    
    //
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, viewW, 20)];
    _pageControl.center = CGPointMake(viewW * 0.5, viewH - 20);
    _pageControl.pageIndicatorTintColor = KBackgroundColor;
    _pageControl.currentPageIndicatorTintColor = KBaseAppColor;
    _pageControl.numberOfPages = pageCount;
    [self.view addSubview:_pageControl];
    
    //右上角button
    UIButton *intoButton = [[UIButton alloc] initWithFrame:CGRectMake(viewW  - 30, 0, 30, 30)];
    [intoButton setImage:[self buttonCornerImage:intoButton.frame.size] forState:UIControlStateNormal];
    [intoButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:intoButton];
}

- (void)buttonClick:(UIButton *)button {
    if (self.DismissShowBlock) {
        self.DismissShowBlock();
    }
}

- (UIImage *)buttonCornerImage:(CGSize)size {
    CGFloat butonW = size.width;
    CGRect rect = CGRectMake(0, 0, butonW, butonW);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    //裁剪
    [[UIBezierPath bezierPathWithArcCenter:CGPointMake(butonW, 0)
                                    radius:butonW
                                startAngle:-M_PI_2
                                  endAngle:-M_PI
                                 clockwise:YES] addClip];
    //
    [[UIColor lightGrayColor] setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    [[UIImage imageNamed:@"closeButton"] drawInRect:CGRectMake(butonW * 0.4, butonW * 0.2, butonW * 0.4, butonW * 0.4)];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

#pragma mark
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _pageControl.currentPage = (NSInteger)(scrollView.contentOffset.x / scrollView.frame.size.width);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
