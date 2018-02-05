//
//  DDImageBrowserController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/14.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "DDImageBrowserController.h"
#import "DDImageBrowserFlowLayout.h"
#import "DDImageBrowserCell.h"
#import "DDImageBrowserVideo.h"

#import "QRCodeRecognizer.h"

@interface DDImageBrowserController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL statusBarHidden;

@property (nonatomic, strong) UIView *barView;
@property (nonatomic, strong) UILabel *countLabel;

@end

static NSString * const reuseIdentifier = @"Cell";
const CGFloat minLineSpacing = 40;

@implementation DDImageBrowserController

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.barView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    [self showImageOfIndex:self.currentIndex];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark
- (void)backClick:(UIButton *)button {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)recognize:(UIButton *)button {
    [self loading];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        QRCodeRecognizer *code = [[QRCodeRecognizer alloc] init];
        code.codeImage = self.thumbImages[_currentIndex];
        NSString *message = [code getQRString];
        message = message ?:@"未识别到二维码信息";
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHUD];
            [self showAlertWithTitle:@"扫描结果" message:message operationTitle:@"确定" operation:nil];
        });
    });
}

- (void)hideNavigationBar {
    self.statusBarHidden = !self.statusBarHidden;
    self.barView.hidden = self.statusBarHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)setThumbImages:(NSArray *)thumbImages {
    if (_thumbImages.count == 0) {
        _thumbImages = [NSMutableArray arrayWithArray:thumbImages];
    }
}

#pragma mark
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.thumbImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDImageBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    __weak typeof(self) wSelf = self;
    cell.SingleTapBlock = ^{
        [wSelf hideNavigationBar];
    };
    cell.image = self.thumbImages[indexPath.row];
    
    return cell;
}

#pragma mark
- (void)showImageOfIndex:(NSInteger)index {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionLeft
                                        animated:NO];
    self.countLabel.text = [NSString stringWithFormat:@"%ld / %ld",index + 1,self.thumbImages.count];
    if (self.ScrollToIndexBlock) {
        self.ScrollToIndexBlock(self,index);
    }
}

//显示对应页的高清图
- (void)showHighQualityImageOfIndex:(NSInteger)index withImage:(UIImage *)image {
    DDImageBrowserCell *cell = (DDImageBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    cell.image = image;
//    self.thumbImages[index] = image;
}

#pragma mark
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    //减速停止
//    CGFloat pageWidth = CGRectGetWidth(scrollView.frame) + minLineSpacing;
//    NSInteger currentPage = scrollView.contentOffset.x / pageWidth;
//    
//    if (self.currentIndex == currentPage) {
//        return;
//    }
//    
//    self.currentIndex = currentPage;
//    self.countLabel.text = [NSString stringWithFormat:@"%ld / %ld",currentPage + 1,self.thumbImages.count];
//    if (self.ScrollToIndexBlock) {
//        self.ScrollToIndexBlock(self,self.currentIndex);
//    }
//}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGFloat pageWidth = CGRectGetWidth(scrollView.frame) + minLineSpacing;
    
    NSInteger lastPage;
    if (velocity.x == 0) {
        lastPage = roundf(self.collectionView.contentOffset.x / pageWidth);
    } else {
        lastPage = self.collectionView.contentOffset.x / pageWidth;
        NSInteger maxPage = (self.collectionView.contentSize.width + minLineSpacing) / pageWidth - 1;
        
        lastPage = velocity.x < 0 ? lastPage : lastPage + 1;
        lastPage = MIN(MAX(lastPage, 0), maxPage);
    }
    
    if (self.currentIndex == lastPage) {
        return;
    }
    
    self.currentIndex = lastPage;
    self.countLabel.text = [NSString stringWithFormat:@"%ld / %ld",lastPage + 1,self.thumbImages.count];
    if (self.ScrollToIndexBlock) {
        self.ScrollToIndexBlock(self,self.currentIndex);
    }
}

#pragma mark
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        DDImageBrowserFlowLayout *flowLayout = [[DDImageBrowserFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = self.view.bounds.size;
        flowLayout.minimumLineSpacing = minLineSpacing;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                             collectionViewLayout:flowLayout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[DDImageBrowserCell class] forCellWithReuseIdentifier:reuseIdentifier];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    }
    return _collectionView;
}

- (UIView *)barView {
    if (!_barView) {
        _barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
        _barView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.6];
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, _barView.bounds.size.width, 44)];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.font = [UIFont boldSystemFontOfSize:18];
        [_barView addSubview:_countLabel];
        
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 30, 42)];
        UIImage *originalImage = [UIImage imageNamed:@"backButton"];
        [backButton setImage:originalImage forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
        [_barView addSubview:backButton];
        
        UIButton *recognizeButton = [[UIButton alloc] initWithFrame:CGRectMake(_barView.bounds.size.width - 42, 20, 42, 42)];
        [recognizeButton setTitle:@" " forState:UIControlStateNormal];
        [recognizeButton addTarget:self action:@selector(recognize:) forControlEvents:UIControlEventTouchUpInside];
        [_barView addSubview:recognizeButton];
    }
    return _barView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
//    [self showAlertWithTitle:nil message:@"收到内存警告" operationTitle:@"确定" operation:nil];
}

@end
