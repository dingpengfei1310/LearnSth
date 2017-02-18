//
//  DDImageBrowserCell.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/13.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "DDImageBrowserCell.h"

@interface DDImageBrowserCell ()<UIScrollViewDelegate> {
    CGFloat viewWidth;
    CGFloat viewHeight;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *photoImageView;

@end

const CGFloat DDImageBrowserMaxZoom = 2;
const CGFloat DDImageBrowserMinZoom = 1;

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
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.contentView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self.contentView addGestureRecognizer:singleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.contentView addGestureRecognizer:longPress];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [singleTap requireGestureRecognizerToFail:longPress];
}

#pragma mark
- (void)setImage:(UIImage *)image {
    if (_image != image) {
        _image = image;
        [self updateImage:image];
    }
}

//设置图片
- (void)updateImage:(UIImage *)newImage {
    if (!newImage) return;
    
    [self.scrollView setZoomScale:1.0 animated:YES];
    
    _photoImageView.image = newImage;
    CGSize imageSize = newImage.size;
    CGFloat imageScale = imageSize.width / imageSize.height;
    CGFloat imageHeight = viewWidth / imageScale;//宽度充满时，图片的高度
    
    _photoImageView.bounds = CGRectMake(0, 0, viewWidth, imageHeight);
    _photoImageView.center = CGPointMake(viewWidth * 0.5, viewHeight * 0.5);
    if (imageHeight > viewHeight) {
        _photoImageView.center = CGPointMake(viewWidth * 0.5, imageHeight * 0.5);
        
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)gesture {
    CGFloat scale = (self.scrollView.zoomScale == 2.0) ? 1.0 : 2.0;
    [self.scrollView setZoomScale:scale animated:YES];
}

- (void)singleTap:(UITapGestureRecognizer *)gesture {
    if (self.SingleTapBlock) {
        self.SingleTapBlock();
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture {
    if (self.LongPressBlock) {
        self.LongPressBlock();
    }
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
