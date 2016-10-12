//
//  DDImageZoomView.m
//  ReadyJob
//
//  Created by 丁鹏飞 on 16/8/4.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "DDImageZoomView.h"
#import "UIImageView+WebCache.h"

@interface DDImageZoomView ()<UIScrollViewDelegate> {
    CGFloat viewWidth;
    CGFloat viewHeight;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation DDImageZoomView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initImageZoomView];
    }
    return self;
}

- (void)initImageZoomView {
    self.backgroundColor = [UIColor clearColor];
    
    viewWidth = [UIScreen mainScreen].bounds.size.width;
    viewHeight = [UIScreen mainScreen].bounds.size.height;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.maximumZoomScale = DDImageBrowserMaxZoom;
    _scrollView.minimumZoomScale = DDImageBrowserMinZoom;
    [self addSubview:_scrollView];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.userInteractionEnabled = YES;
    _imageView.center = CGPointMake(viewWidth * 0.5, viewHeight * 0.5);
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_imageView];
    
}

- (void)setImageWithUrl:(NSURL *)url placeholderIamge:(UIImage *)placeholder {
    [self updateImage:placeholder];
    
    [_imageView sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
        } else {
            [self updateImage:image];
        }
    }];
}

//设置图片
- (void)updateImage:(UIImage *)newImage {
    _imageView.image = newImage;
    CGSize imaegSize = newImage.size;
    CGFloat imageScale = imaegSize.width / imaegSize.height;
    CGFloat imageHeight = viewWidth / imageScale;//宽度充满时，图片的高度
    
    _imageView.bounds = CGRectMake(0, 0, viewWidth, imageHeight);
    if (imageHeight > viewHeight) {
        _imageView.center = CGPointMake(viewWidth * 0.5, imageHeight * 0.5);
        [self.scrollView setZoomScale:1.0 animated:YES];
    }
    
}

- (void)doubleTapToZommWithScale:(CGFloat)scale {
    if (self.scrollView.zoomScale == 1) {
        [self.scrollView setZoomScale:DDImageBrowserMaxZoom animated:YES];
    } else {
        [self.scrollView setZoomScale:1 animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGSize boundsSize = scrollView.bounds.size;
    CGSize contentSize = _imageView.frame.size;
    
    CGPoint centerPoint = CGPointMake(MAX(contentSize.width, boundsSize.width) * 0.5, MAX(contentSize.height, boundsSize.height) * 0.5);
    _imageView.center = centerPoint;
}

@end
