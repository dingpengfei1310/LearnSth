//
//  BannerScrollView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/5.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "BannerScrollView.h"
#import "UIImageView+WebCache.h"
#import "AppConfiguration.h"

@interface BannerScrollView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *centerImageView;
@property (nonatomic, strong) UIImageView *rightImageView;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation BannerScrollView {
    CGFloat width;
    CGFloat height;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        width = frame.size.width;
        height = frame.size.height;
        
        [self addSubview:self.indicatorView];
        [self.indicatorView startAnimating];
    }
    return self;
}

- (void)setImageArray:(NSArray *)imageArray {
    _imageArray = imageArray;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    [self addSubview:self.scrollView];
    
    for (int i = 0; i < 3; i++) {
        NSInteger index = (imageArray.count - 1 + i) % imageArray.count;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(width * i, 0, width, height)];
        imageView.userInteractionEnabled = YES;
        NSURL *url = [NSURL URLWithString:imageArray[index]];
        [imageView sd_setImageWithURL:url placeholderImage:nil];
        [self.scrollView addSubview:imageView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick)];
        [imageView addGestureRecognizer:tapGesture];
        
        if (i == 0) {
            self.leftImageView = imageView;
        } else if (i == 1) {
            self.centerImageView = imageView;
        } else {
            self.rightImageView = imageView;
        }
    }
    
    [self.scrollView setContentOffset:CGPointMake(width, 0)];
    if (imageArray.count > 1) {
        [self addSubview:self.pageControl];
        self.pageControl.numberOfPages = imageArray.count;
        self.pageControl.currentPage = 0;
        
        self.scrollView.contentSize = CGSizeMake(width * 3, height);
        
        [self setUpTimer];
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self setUpTimer];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self invalidateTimer];
    [self calculateCurrrentPage:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self calculateCurrrentPage:scrollView];
}

#pragma mark
- (void)setUpTimer {
    if (self.imageArray.count < 2) {
        return;
    }
    if (!_timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                      target:self
                                                    selector:@selector(autoScroll)
                                                    userInfo:nil
                                                     repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    
}

- (void)invalidateTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)calculateCurrrentPage:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x > width) {
        self.currentPage = (self.currentPage + 1 ) % self.imageArray.count;
        
    } else if (scrollView.contentOffset.x < width) {
        self.currentPage = (self.imageArray.count + self.currentPage - 1 ) % self.imageArray.count;
    }
    [self scrollToCenter];
}

- (void)scrollToCenter {
    NSInteger leftPage;
    NSInteger rightPage;
    
    leftPage = (self.imageArray.count + self.currentPage - 1 ) % self.imageArray.count;
    rightPage = (self.currentPage + 1 ) % self.imageArray.count;
    
    [self.leftImageView sd_setImageWithURL:[NSURL URLWithString:self.imageArray[leftPage]]
                          placeholderImage:nil];
    
    [self.centerImageView sd_setImageWithURL:[NSURL URLWithString:self.imageArray[self.currentPage]]
                            placeholderImage:nil];
    
    [self.rightImageView sd_setImageWithURL:[NSURL URLWithString:self.imageArray[rightPage]]
                           placeholderImage:nil];
    
    self.pageControl.currentPage = self.currentPage;
    [self.scrollView setContentOffset:CGPointMake(width, 0)];
}

- (void)imageClick {
    if (self.imageClickBlock) {
        self.imageClickBlock(self.currentPage);
    }
}

- (void)autoScroll {
    self.currentPage = (self.currentPage + 1 ) % self.imageArray.count;
    [self scrollToCenter];
}

#pragma mark
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.bounces = NO;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        CGFloat pageWidth = self.imageArray.count * 20;
        CGRect pageRect = CGRectMake(width - pageWidth, height - 15, pageWidth, 10);
        _pageControl = [[UIPageControl alloc] initWithFrame:pageRect];
        _pageControl.pageIndicatorTintColor = KBackgroundColor;
        _pageControl.currentPageIndicatorTintColor = KBaseBlueColor;
    }
    return _pageControl;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.frame = CGRectMake(0, 0, 20, 20);
        _indicatorView.center = CGPointMake(width * 0.5, height * 0.5);
    }
    
    return _indicatorView;
}


@end


