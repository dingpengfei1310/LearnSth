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

@interface DDImageBrowserController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL statusBarHidden;

@property (nonatomic, strong) UIView *barView;

@end

static NSString * const reuseIdentifier = @"Cell";

@implementation DDImageBrowserController

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.barView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showImageOfIndex:self.currentIndex];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark
- (void)backClick:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hideNavigationBar {
    self.barView.hidden = !self.barView.hidden;
    self.statusBarHidden = !self.statusBarHidden;
    [self prefersStatusBarHidden];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)setThumbImages:(NSArray *)thumbImages {
    if (_thumbImages.count == 0) {
        _thumbImages = [NSMutableArray arrayWithArray:thumbImages];
    }
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.thumbImages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDImageBrowserCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    cell.SingleTapBlock = ^{
        [self hideNavigationBar];
    };
    cell.image = self.thumbImages[indexPath.row];
    return cell;
}

#pragma mark
- (void)showImageOfIndex:(NSInteger)index {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop animated:NO];
    self.title = [NSString stringWithFormat:@"%ld / %ld",index + 1,self.thumbImages.count];
    if (self.ScrollToIndexBlock) {
        self.ScrollToIndexBlock(self,index);
    }
}

- (void)showHighQualityImageOfIndex:(NSInteger)index WithAsset:(PHAsset *)asset {
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        
        UIImage *result = [UIImage imageWithData:imageData];
        DDImageBrowserCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.image = result;
        self.thumbImages[index] = result;
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!self.thumbImages) return;
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:scrollView.contentOffset];
    if (self.currentIndex == indexPath.row) {
        return;
    }
    
    self.currentIndex = indexPath.row;
    self.title = [NSString stringWithFormat:@"%ld / %ld",indexPath.row + 1,self.thumbImages.count];
    if (self.ScrollToIndexBlock) {
        self.ScrollToIndexBlock(self,self.currentIndex);
    }
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Screen_H, Screen_W)
                                                  style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.pagingEnabled = YES;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.rowHeight = Screen_W;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _tableView.transform = CGAffineTransformMakeRotation(- M_PI_2);
        _tableView.center = CGPointMake(Screen_W * 0.5, Screen_H * 0.5);
        [_tableView registerClass:[DDImageBrowserCell class] forCellReuseIdentifier:reuseIdentifier];
    }
    
    return _tableView;
}

- (UIView *)barView {
    if (!_barView) {
        _barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_W, 64)];
        _barView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
        
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 42, 42)];
        UIImage *originalImage = [UIImage imageNamed:@"backButtonImage"];
        [backButton setImage:originalImage forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
        [_barView addSubview:backButton];
    }
    return _barView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
