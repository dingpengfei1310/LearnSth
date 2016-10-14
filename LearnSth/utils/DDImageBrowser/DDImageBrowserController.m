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
@property (nonatomic, strong) UILabel *currentIndexLabel;

@end

static NSString * const reuseIdentifier = @"Cell";

@implementation DDImageBrowserController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    viewWidth = [UIScreen mainScreen].bounds.size.width;
    viewHeight = [UIScreen mainScreen].bounds.size.height;
    
    //点击
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(singleTapAction:)];
    [singleTap setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:singleTap];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.currentIndexLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.imageCount > 0) {
        [self showImageOfIndex:self.currentIndex];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, viewHeight, viewWidth)
                                                  style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.pagingEnabled = YES;
        _tableView.rowHeight = viewWidth;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.transform = CGAffineTransformMakeRotation(- M_PI_2);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.center = CGPointMake(viewWidth * 0.5, viewHeight * 0.5);
        [_tableView registerClass:[DDImageBrowserCell class] forCellReuseIdentifier:reuseIdentifier];
    }
    
    return _tableView;
}

- (UILabel *)currentIndexLabel {
    if (!_currentIndexLabel) {
        _currentIndexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, viewHeight - 40, viewWidth, 20)];
        _currentIndexLabel.backgroundColor = [UIColor clearColor];
        _currentIndexLabel.textColor = [UIColor whiteColor];
        _currentIndexLabel.font = [UIFont systemFontOfSize:15];
        _currentIndexLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentIndexLabel;
}

- (void)setThumbImages:(NSArray *)thumbImages {
    _thumbImages = thumbImages;
    self.imageCount = thumbImages.count;
}

#pragma mark - UITableViewDataSource

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
//点击移出
- (void)singleTapAction:(UITapGestureRecognizer *)recognizer {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showImageOfIndex:(NSInteger)index {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop animated:NO];
    self.currentIndexLabel.text = [NSString stringWithFormat:@"%ld / %ld",index + 1,self.imageCount];
    
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
    self.currentIndexLabel.text = [NSString stringWithFormat:@"%ld / %ld",indexPath.row + 1,self.imageCount];
    
    if ([self.browserDelegate respondsToSelector:@selector(controller:didScrollToIndex:)]) {
        [self.browserDelegate controller:self didScrollToIndex:indexPath.row];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
