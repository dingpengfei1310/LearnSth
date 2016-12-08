//
//  LiveViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/28.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "LiveViewController.h"
#import "PLPlayerViewController.h"

#import "MJRefresh.h"
#import "HttpManager.h"
#import "LiveModel.h"
#import "UIImageView+WebCache.h"

#import "UICollectionView+Tool.h"
#import "Aspects.h"

@interface LiveViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) NSArray *liveList;
@property (nonatomic, assign) NSInteger page;

@end

static NSString *identifier = @"cell";

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"^_^";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"  " style:UIBarButtonItemStylePlain target:self action:@selector(hideCollectionView)];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView.mj_header beginRefreshing];
    
    __weak typeof(self) weakSelf = self;
    [self.collectionView setClickBlock:^{
        [weakSelf.collectionView.mj_header beginRefreshing];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.collectionView aspect_hookSelector:@selector(reloadData) withOptions:AspectPositionBefore usingBlock:^{
        [self.collectionView checkEmpty];
    } error:NULL];
}

#pragma mark
- (void)refreshData {
    [[HttpManager shareManager] getHotLiveListWithParamers:nil completion:^(NSArray *list, NSError *error) {
        [self.collectionView.mj_header endRefreshing];
        
        if (error) {
            [self showErrorWithError:error];
        } else {
            self.liveList = [LiveModel liveWithArray:list];
        }
        [self.collectionView reloadData];
    }];
}

- (void)hideCollectionView {
    self.collectionView.hidden = !self.collectionView.hidden;
}

#pragma mark
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.liveList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    [cell.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    cell.backgroundColor = [UIColor whiteColor];
    
    LiveModel *model = self.liveList[indexPath.item];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
    [imageView sd_setImageWithURL:[NSURL URLWithString:model.smallpic] placeholderImage:nil];
    [cell.contentView addSubview:imageView];
    
//    CGFloat itemWidth = CGRectGetWidth(cell.bounds);
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, itemWidth - 25, itemWidth, 25)];
//    label.font = [UIFont systemFontOfSize:10];
//    label.textColor = [UIColor whiteColor];
//    label.text = model.signatures;
//    label.numberOfLines = 0;
//    [cell.contentView addSubview:label];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PLPlayerViewController *controller = [[PLPlayerViewController alloc] init];
    controller.live = self.liveList[indexPath.item];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat itemWidth = (ScreenWidth - 30) / 2;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        
        CGRect collectionViewRect = CGRectMake(0, ViewFrameOrigin_X, ScreenWidth, ScreenHeight - 113);
        _collectionView = [[UICollectionView alloc] initWithFrame:collectionViewRect
                                             collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = KBackgroundColor;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:identifier];
        
        NSArray *images = @[[UIImage imageNamed:@"reflesh1"],[UIImage imageNamed:@"reflesh2"],[UIImage imageNamed:@"reflesh3"]];
        
        MJRefreshGifHeader *gifHeader = [MJRefreshGifHeader headerWithRefreshingTarget:self
                                                                      refreshingAction:@selector(refreshData)];
        [gifHeader setImages:images forState:MJRefreshStatePulling];
        [gifHeader setImages:images forState:MJRefreshStateRefreshing];
        
        gifHeader.lastUpdatedTimeLabel.hidden = YES;
        gifHeader.stateLabel.hidden = YES;
        
        _collectionView.mj_header = gifHeader;
    }
    
    return _collectionView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end