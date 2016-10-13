//
//  DDImageBrowserView.m
//  ReadyJob
//
//  Created by 丁鹏飞 on 16/8/4.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "DDImageBrowserView.h"
#import "DDImageZoomView.h"

#import <objc/runtime.h>

@interface DDImageBrowserView ()<UITableViewDataSource,UITableViewDelegate> {
    CGFloat viewWidth;
    CGFloat viewHeight;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *currentIndexLabel;

@end

static NSString * const identifier = @"Cell";
static char imageZoomViewKey;


@implementation DDImageBrowserView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        
        viewWidth = [UIScreen mainScreen].bounds.size.width;
        viewHeight = [UIScreen mainScreen].bounds.size.height;
        
        [self initImageBrowserView];
    }
    return self;
}

- (void)initImageBrowserView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, viewHeight, viewWidth)
                                              style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.pagingEnabled = YES;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.transform = CGAffineTransformMakeRotation(- M_PI_2);
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.center = CGPointMake(viewWidth * 0.5, viewHeight * 0.5);
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    [self addSubview:_tableView];
    
    _currentIndexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, viewHeight - 40, viewWidth, 20)];
    _currentIndexLabel.backgroundColor = [UIColor clearColor];
    _currentIndexLabel.textColor = [UIColor whiteColor];
    _currentIndexLabel.font = [UIFont systemFontOfSize:15];
    _currentIndexLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_currentIndexLabel];
    
    _currentIndexLabel.text = [NSString stringWithFormat:@"%d / %ld",1,self.imageCount];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.imageCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    cell.contentView.transform = CGAffineTransformMakeRotation(M_PI_2);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    DDImageZoomView *imageView = [[DDImageZoomView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    [cell.contentView addSubview:imageView];
    
    [imageView setImageWithUrl:[self imageUrlOfIndex:indexPath.row]
              placeholderIamge:[self placeholderImageOfIndex:indexPath.row]];
    
    objc_setAssociatedObject(cell, &imageZoomViewKey, imageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    //单击
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    [singleTap setNumberOfTapsRequired:1];
    [imageView addGestureRecognizer:singleTap];
    
    //双击
//    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
//    [doubleTap setNumberOfTapsRequired:2];
//    [imageView addGestureRecognizer:doubleTap];
//    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return viewWidth;
}

#pragma mark
- (UIImage *)placeholderImageOfIndex:(NSInteger)index {
    if ([self.imageBrowserDelegate respondsToSelector:@selector(imageBrowser:placeholderImageOfIndex:)]) {
        return [self.imageBrowserDelegate imageBrowser:self placeholderImageOfIndex:index];
    }
    return nil;
}

- (NSURL *)imageUrlOfIndex:(NSInteger)index {
    if ([self.imageBrowserDelegate respondsToSelector:@selector(imageBrowser:imageUrlOfIndex:)]) {
        return [self.imageBrowserDelegate imageBrowser:self imageUrlOfIndex:index];
    }
    return nil;
}

#pragma mark
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:scrollView.contentOffset];
    self.currentIndexLabel.text = _currentIndexLabel.text = [NSString stringWithFormat:@"%ld / %ld",indexPath.row + 1,self.imageCount];
    
    if ([self.imageBrowserDelegate respondsToSelector:@selector(imageBrowser:didScrollToIndex:)]) {
        [self.imageBrowserDelegate imageBrowser:self didScrollToIndex:indexPath.row];
    }
    
}

#pragma mark
//双击
- (void)doubleTapAction:(UITapGestureRecognizer *)recognizer {
    DDImageZoomView *zoomView = (DDImageZoomView *)recognizer.view;
    [zoomView doubleTapToZommWithScale:1];
}

//移出
- (void)singleTapAction:(UITapGestureRecognizer *)recognizer {
    
    [UIView animateWithDuration:DDImageBrowserHideAnimationDuration animations:^{
        self.transform = CGAffineTransformMakeTranslation(viewWidth, 0);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

//展示
- (void)show {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    
    self.transform = CGAffineTransformMakeTranslation(viewWidth, 0);
    [UIView animateWithDuration:DDImageBrowserShowAnimationDuration animations:^{
        self.transform = CGAffineTransformIdentity;
    }];
}

- (void)selectImageOfIndex:(NSInteger)index {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    self.currentIndexLabel.text = _currentIndexLabel.text = [NSString stringWithFormat:@"%ld / %ld",index + 1,self.imageCount];
    
    if ([self.imageBrowserDelegate respondsToSelector:@selector(imageBrowser:didScrollToIndex:)]) {
        [self.imageBrowserDelegate imageBrowser:self didScrollToIndex:index];
    }
}

- (void)setImageOfIndex:(NSInteger)index withImage:(UIImage *)image {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    DDImageZoomView *imageZoomView = objc_getAssociatedObject(cell, &imageZoomViewKey);
    [imageZoomView setImageWithUrl:nil placeholderIamge:image];
}


@end



