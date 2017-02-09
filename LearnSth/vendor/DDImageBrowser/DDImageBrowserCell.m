//
//  DDImageBrowserCell.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/13.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "DDImageBrowserCell.h"

#import "UIImageView+WebCache.h"

@interface DDImageBrowserCell ()<UIScrollViewDelegate> {
    CGFloat viewWidth;
    CGFloat viewHeight;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *photoImageView;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation DDImageBrowserCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        [self initImageZoomView];
    }
    return self;
}

- (void)initImageZoomView {
    viewWidth = [UIScreen mainScreen].bounds.size.width;
    viewHeight = [UIScreen mainScreen].bounds.size.height;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.userInteractionEnabled = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.maximumZoomScale = DDImageBrowserMaxZoom;
    _scrollView.minimumZoomScale = DDImageBrowserMinZoom;
    
    _photoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _photoImageView.center = CGPointMake(viewWidth * 0.5, viewHeight * 0.5);
    _photoImageView.bounds = CGRectMake(0, 0, viewWidth, viewHeight);
    _photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_photoImageView];
    
    [self.contentView addSubview:_scrollView];
    
    [self.contentView addGestureRecognizer:_scrollView.pinchGestureRecognizer];
    [self.contentView addGestureRecognizer:_scrollView.panGestureRecognizer];
}

- (void)setImageWithUrl:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    self.scrollView.zoomScale = 1.0;
    [self updateImage:placeholder];//首先显示本地图片
    
    //加载网络图片
    if (!url) return;
    [self startActivityIndicatorView];
    [_photoImageView sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [self stopActivityIndicatorView];
        
        if (error) {
        } else {
            [self updateImage:image];
        }
    }];
}

//设置图片
- (void)updateImage:(UIImage *)newImage {
    if (!newImage) return;
    
    _photoImageView.image = newImage;
    CGSize imageSize = newImage.size;
    CGFloat imageScale = imageSize.width / imageSize.height;
    CGFloat imageHeight = viewWidth / imageScale;//宽度充满时，图片的高度
    
    _photoImageView.bounds = CGRectMake(0, 0, viewWidth, imageHeight);
    _photoImageView.center = CGPointMake(viewWidth * 0.5, viewHeight * 0.5);
    
    if (imageHeight > viewHeight) {
        _photoImageView.center = CGPointMake(viewWidth * 0.5, imageHeight * 0.5);
        [self.scrollView setZoomScale:1.0 animated:YES];
    }
}

#pragma mark
- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.frame = CGRectMake(0, 0, 20, 20);
        [_activityIndicatorView startAnimating];
        _activityIndicatorView.center = CGPointMake(viewWidth * 0.5, viewHeight * 0.5);
    }
    return _activityIndicatorView;
}

- (void)startActivityIndicatorView {
    [self.scrollView addSubview:self.activityIndicatorView];
}

- (void)stopActivityIndicatorView {
    [self.activityIndicatorView removeFromSuperview];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _photoImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGSize boundSize = scrollView.bounds.size;
    CGSize contentSize = _photoImageView.frame.size;
    
    CGPoint centerPoint = CGPointMake(MAX(contentSize.width, boundSize.width) * 0.5, MAX(contentSize.height, boundSize.height) * 0.5);
    _photoImageView.center = centerPoint;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
