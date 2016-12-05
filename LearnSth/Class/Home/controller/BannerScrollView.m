//
//  BannerScrollView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/5.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "BannerScrollView.h"
#import "UIImageView+WebCache.h"

@interface BannerScrollView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *centerImageView;
@property (nonatomic, strong) UIImageView *rightImageView;

@end

@implementation BannerScrollView {
    CGFloat width;
    CGFloat height;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        width = frame.size.width;
        height = frame.size.height;
    }
    return self;
}

- (void)setImageArray:(NSArray *)imageArray {
    _imageArray = imageArray;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    [self addSubview:self.scrollView];
    if (imageArray.count > 1) {
        [self addSubview:self.pageControl];
        self.pageControl.numberOfPages = imageArray.count;
        self.pageControl.currentPage = 0;
        
        self.scrollView.contentSize = CGSizeMake(width * 3, height);
    }
    
    for (int i = 0; i < 3; i++) {
        NSInteger index = (imageArray.count - 1 + i) % imageArray.count;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(width * i, 0, width, height)];
        imageView.userInteractionEnabled = YES;
        NSURL *url = [NSURL URLWithString:imageArray[index]];
        [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"defaultHeader"]];
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
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self scrollToCenter:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollToCenter:scrollView];
}

- (void)scrollToCenter:(UIScrollView *)scrollView {
    NSInteger leftPage;
    NSInteger rightPage;
    
    if (scrollView.contentOffset.x > width) {
        self.currentPage = (self.currentPage + 1 ) % self.imageArray.count;
        
    } else if (scrollView.contentOffset.x < width) {
        self.currentPage = (self.imageArray.count + self.currentPage - 1 ) % self.imageArray.count;
    }
    
    leftPage = (self.imageArray.count + self.currentPage - 1 ) % self.imageArray.count;
    rightPage = (self.currentPage + 1 ) % self.imageArray.count;
    
    [self.leftImageView sd_setImageWithURL:[NSURL URLWithString:self.imageArray[leftPage]]
                          placeholderImage:[UIImage imageNamed:@"defaultHeader"]];
    
    [self.centerImageView sd_setImageWithURL:[NSURL URLWithString:self.imageArray[self.currentPage]]
                            placeholderImage:[UIImage imageNamed:@"defaultHeader"]];
    
    [self.rightImageView sd_setImageWithURL:[NSURL URLWithString:self.imageArray[rightPage]]
                           placeholderImage:[UIImage imageNamed:@"defaultHeader"]];
    
    self.pageControl.currentPage = self.currentPage;
    [scrollView setContentOffset:CGPointMake(width, 0)];
}

- (void)imageClick {
    if (self.imageClickBlock) {
        self.imageClickBlock(self.currentPage);
    }
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
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, height - 20, width, 20)];
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    }
    return _pageControl;
}

@end
