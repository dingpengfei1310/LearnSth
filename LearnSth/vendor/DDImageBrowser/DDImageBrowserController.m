//
//  DDImageBrowserController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/14.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "DDImageBrowserController.h"

#import "DDImageBrowserCell.h"

@interface DDImageBrowserController ()<UITableViewDataSource,UITableViewDelegate> {
    CGFloat viewWidth;
    CGFloat viewHeight;
}

@property (nonatomic, strong) UITableView *tableView;

@end

static NSString * const reuseIdentifier = @"Cell";

@implementation DDImageBrowserController
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    viewWidth = [UIScreen mainScreen].bounds.size.width;
    viewHeight = [UIScreen mainScreen].bounds.size.height;
    
    [self.view addSubview:self.tableView];
//    [self.view addSubview:self.currentIndexLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.hidesBarsOnTap = YES;
    if (self.imageCount > 0) {
        [self showImageOfIndex:self.currentIndex];
    } else {
        [self backClick:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.hidesBarsOnTap = NO;
}

#pragma mark
- (void)backClick:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setThumbImages:(NSArray *)thumbImages {
    _thumbImages = thumbImages;
    self.imageCount = thumbImages.count;
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.imageCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDImageBrowserCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (self.thumbImages) {
        [cell setImageWithUrl:[self imageUrlOfIndex:indexPath.row]
             placeholderImage:self.thumbImages[indexPath.row]];
    } else {
        [cell setImageWithUrl:[self imageUrlOfIndex:indexPath.row]
             placeholderImage:[self placeholderImageOfIndex:indexPath.row]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if ([self.browserDelegate respondsToSelector:@selector(controller:didSelectAtIndex:)]) {
//        [self.browserDelegate controller:self didSelectAtIndex:indexPath.row];
//    }
}

#pragma mark
- (UIImage *)placeholderImageOfIndex:(NSInteger)index {
    if ([self.browserDelegate respondsToSelector:@selector(controller:placeholderImageOfIndex:)]) {
        return [self.browserDelegate controller:self placeholderImageOfIndex:index];
    }
    return nil;
}

- (NSURL *)imageUrlOfIndex:(NSInteger)index {
    if ([self.browserDelegate respondsToSelector:@selector(controller:imageUrlOfIndex:)]) {
        return [self.browserDelegate controller:self imageUrlOfIndex:index];
    }
    return nil;
}

#pragma mark
- (void)showImageOfIndex:(NSInteger)index {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop animated:NO];
//    self.currentIndexLabel.text = [NSString stringWithFormat:@"%ld / %ld",index + 1,self.imageCount];
    self.title = [NSString stringWithFormat:@"%ld / %ld",index + 1,self.imageCount];
    
    if ([self.browserDelegate respondsToSelector:@selector(controller:didScrollToIndex:)]) {
        [self.browserDelegate controller:self didScrollToIndex:index];
    }
}

- (void)showHighQualityImageOfIndex:(NSInteger)index withImage:(UIImage *)image {
    DDImageBrowserCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell setImageWithUrl:nil placeholderImage:image];
}

#pragma mark
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!self.imageCount) return;
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:scrollView.contentOffset];
//    self.currentIndexLabel.text = [NSString stringWithFormat:@"%ld / %ld",indexPath.row + 1,self.imageCount];
    self.title = [NSString stringWithFormat:@"%ld / %ld",indexPath.row + 1,self.imageCount];
    
    if ([self.browserDelegate respondsToSelector:@selector(controller:didScrollToIndex:)]) {
        [self.browserDelegate controller:self didScrollToIndex:indexPath.row];
    }
    
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, viewHeight, viewWidth)
                                                  style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.pagingEnabled = YES;
        _tableView.showsVerticalScrollIndicator = NO;
        
        _tableView.rowHeight = viewWidth;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _tableView.transform = CGAffineTransformMakeRotation(- M_PI_2);
        _tableView.center = CGPointMake(viewWidth * 0.5, viewHeight * 0.5);
        [_tableView registerClass:[DDImageBrowserCell class] forCellReuseIdentifier:reuseIdentifier];
    }
    
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
