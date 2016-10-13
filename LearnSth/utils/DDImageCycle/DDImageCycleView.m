//
//  DDImageCycleView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/13.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "DDImageCycleView.h"

#import "UIImageView+WebCache.h"

@interface DDImageCycleView ()<UIScrollViewDelegate> {
    CGFloat width;
    CGFloat height;
}

//轮播的图片数组
@property (nonatomic, strong) NSMutableArray *images;

@property (nonatomic , strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIImageView *currImageView;
@property (nonatomic, assign) NSInteger currIndex;

//滚动显示的imageView
@property (nonatomic, strong) UIImageView *otherImageView;
//将要显示图片的索引
@property (nonatomic, assign) NSInteger nextIndex;

@end

@implementation DDImageCycleView

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        
        //添加手势监听图片的点击
//        [_scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick)]];
        _currImageView = [[UIImageView alloc] init];
        [_scrollView addSubview:_currImageView];
        _otherImageView = [[UIImageView alloc] init];
        [_scrollView addSubview:_otherImageView];
    }
    return _scrollView;
}

#pragma mark- 构造方法
- (instancetype)initWithFrame:(CGRect)frame imageArray:(NSArray *)imageArray {
    if (self = [super initWithFrame:frame]) {
        self.imageArray = imageArray;
    }
    return self;
}

//- (instancetype)initWithImageArray:(NSArray *)imageArray imageClickBlock:(void(^)(NSInteger index))imageClickBlock {
//    if (self = [self initWithFrame:CGRectZero imageArray:imageArray]) {
//        self.imageClickBlock = imageClickBlock;
//    }
//    return self;
//}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self addSubview:self.scrollView];
//    [self addSubview:self.describeLabel];
    [self addSubview:self.pageControl];
}

#pragma mark 设置图片数组
- (void)setImageArray:(NSArray *)imageArray{
    if (!imageArray.count) return;
    _imageArray = imageArray;
    _images = [NSMutableArray array];
    
    for (int i = 0; i < imageArray.count; i++) {
        if ([imageArray[i] isKindOfClass:[UIImage class]]) {
            [_images addObject:imageArray[i]];
        } else if ([imageArray[i] isKindOfClass:[NSString class]]){
            //如果是网络图片，则先添加占位图片，下载完成后替换
            [_images addObject:[UIImage imageNamed:@"lookup"]];
            [self downloadImages:i];
        }
    }
    
    //防止在滚动过程中重新给imageArray赋值时报错
    if (_currIndex >= _images.count) _currIndex = _images.count - 1;
    self.currImageView.image = _images[_currIndex];
//    self.describeLabel.text = _describeArray[_currIndex];
//    self.pageControl.numberOfPages = _images.count;
    [self layoutSubviews];
}

- (void)downloadImages:(NSInteger)index {
    NSString *imageUrlString = _imageArray[index];
    
    [_currImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        self.images[index] = image;
        
        if (_currIndex == index) {
            [_currImageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
        }
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //有导航控制器时，会默认在scrollview上方添加64的内边距，这里强制设置为0
    _scrollView.contentInset = UIEdgeInsetsZero;
    
    _scrollView.frame = self.bounds;
//    _describeLabel.frame = CGRectMake(0, self.height - DES_LABEL_H, self.width, DES_LABEL_H);
    //重新计算pageControl的位置
//    self.pagePosition = self.pagePosition;
    [self setScrollViewContentSize];
}

- (void)setScrollViewContentSize {
    if (_images.count > 1) {
        self.scrollView.contentSize = CGSizeMake(self.width * 5, 0);
        self.scrollView.contentOffset = CGPointMake(self.width * 2, 0);
        self.currImageView.frame = CGRectMake(self.width * 2, 0, self.width, self.height);
        if (_changeMode == ChangeModeFade) {
            //淡入淡出模式，两个imageView都在同一位置，改变透明度就可以了
            _currImageView.frame = CGRectMake(0, 0, self.width, self.height);
            _otherImageView.frame = self.currImageView.frame;
            _otherImageView.alpha = 0;
            [self insertSubview:self.currImageView atIndex:0];
            [self insertSubview:self.otherImageView atIndex:1];
        }
//        [self startTimer];
    } else {
        //只要一张图片时，scrollview不可滚动，且关闭定时器
        self.scrollView.contentSize = CGSizeZero;
        self.scrollView.contentOffset = CGPointZero;
        self.currImageView.frame = CGRectMake(0, 0, self.width, self.height);
//        [self stopTimer];
    }
}

- (CGFloat)height {
    return self.scrollView.frame.size.height;
}

- (CGFloat)width {
    return self.scrollView.frame.size.width;
}

#pragma mark- --------UIScrollViewDelegate--------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (CGSizeEqualToSize(CGSizeZero, scrollView.contentSize)) return;
    CGFloat offsetX = scrollView.contentOffset.x;
    //滚动过程中改变pageControl的当前页码
//    [self changeCurrentPageWithOffset:offsetX];
    
//    //向右滚动
    if (offsetX < self.width * 2) {
        if (_changeMode == ChangeModeFade) {
            self.currImageView.alpha = offsetX / self.width - 1;
            self.otherImageView.alpha = 2 - offsetX / self.width;
        } else self.otherImageView.frame = CGRectMake(self.width, 0, self.width, self.height);
        
        self.nextIndex = self.currIndex - 1;
        if (self.nextIndex < 0) self.nextIndex = _images.count - 1;
        if (offsetX <= self.width) [self changeToNext];
//
//        //向左滚动
    } else if (offsetX > self.width * 2){
        if (_changeMode == ChangeModeFade) {
            self.otherImageView.alpha = offsetX / self.width - 2;
            self.currImageView.alpha = 3 - offsetX / self.width;
        } else self.otherImageView.frame = CGRectMake(CGRectGetMaxX(_currImageView.frame), 0, self.width, self.height);
        
        self.nextIndex = (self.currIndex + 1) % _images.count;
        if (offsetX >= self.width * 3) [self changeToNext];
    }
    self.otherImageView.image = self.images[self.nextIndex];
}

- (void)changeToNext {
    if (_changeMode == ChangeModeFade) {
        self.currImageView.alpha = 1;
        self.otherImageView.alpha = 0;
    }
    //切换到下一张图片
    self.currImageView.image = self.otherImageView.image;
    self.scrollView.contentOffset = CGPointMake(self.width * 2, 0);
    self.currIndex = self.nextIndex;
    self.pageControl.currentPage = self.currIndex;
//    self.describeLabel.text = self.describeArray[self.currIndex];
}

@end


