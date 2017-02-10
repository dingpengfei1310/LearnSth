//
//  DDImageBrowserController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/14.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "DDImageBrowserController.h"
#import "DDImageBrowserCell.h"
#import "DDImageBrowserVideo.h"

#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

@interface DDImageBrowserController ()<UITableViewDataSource,UITableViewDelegate> {
    CGFloat viewWidth;
    CGFloat viewHeight;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL statusBarHidden;

@end

static NSString * const reuseIdentifier = @"Cell";

@implementation DDImageBrowserController

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    viewWidth = [UIScreen mainScreen].bounds.size.width;
    viewHeight = [UIScreen mainScreen].bounds.size.height;
    
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showImageOfIndex:self.currentIndex];
}

#pragma mark
- (void)backClick:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hideNavigationBar {
    self.statusBarHidden = !self.statusBarHidden;
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden];
    [self prefersStatusBarHidden];
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.thumbImages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDImageBrowserCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    cell.image = self.thumbImages[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if ([self.browserDelegate respondsToSelector:@selector(controller:didSelectAtIndex:)]) {
//        [self.browserDelegate controller:self didSelectAtIndex:indexPath.row];
//    }
    [self hideNavigationBar];
}

#pragma mark
- (void)showImageOfIndex:(NSInteger)index {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop animated:NO];
    self.title = [NSString stringWithFormat:@"%ld / %ld",index + 1,self.thumbImages.count];
    
    if ([self.browserDelegate respondsToSelector:@selector(controller:didScrollToIndex:)]) {
        [self.browserDelegate controller:self didScrollToIndex:index];
    }
}

- (void)showHighQualityImageOfIndex:(NSInteger)index WithAsset:(PHAsset *)asset {
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        
        UIImage *result = [UIImage imageWithData:imageData];
        DDImageBrowserCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.image = result;
    }];
}

#pragma mark
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!self.thumbImages) return;
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:scrollView.contentOffset];
    if (self.currentIndex == indexPath.row) {
        return;
    }
    
    self.currentIndex = indexPath.row;
    self.title = [NSString stringWithFormat:@"%ld / %ld",indexPath.row + 1,self.thumbImages.count];
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
