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
#import "HttpRequestManager.h"

#import "LiveModel.h"

@interface LiveViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *list;

@end

static NSString *identifier = @"cell";

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat itemWidth = (ScreenWidth - 30) / 2;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64 - 50) collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _collectionView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:identifier];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.view addSubview:_collectionView];
    
    NSArray *images = @[[UIImage imageNamed:@"reflesh1"],[UIImage imageNamed:@"reflesh2"],[UIImage imageNamed:@"reflesh3"]];
    
    MJRefreshGifHeader *gifHeader = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    [gifHeader setImages:images forState:MJRefreshStatePulling];
    [gifHeader setImages:images forState:MJRefreshStateRefreshing];
    
    gifHeader.lastUpdatedTimeLabel.hidden = YES;
    gifHeader.stateLabel.hidden = YES;
    
    _collectionView.mj_header = gifHeader;
    [_collectionView.mj_header beginRefreshing];
}

- (void)refreshData {
    [[HttpRequestManager shareManager] getHotLiveListWithParamer:nil success:^(id responseData) {
        [self.collectionView.mj_header endRefreshing];
        
        NSArray *array = [LiveModel liveWithArray:responseData];
        self.list = [NSArray arrayWithArray:array];
        [self.collectionView reloadData];
        
    } failure:^(NSError *error) {
        [self.collectionView.mj_header endRefreshing];
    }];
}

#pragma mark
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.list.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    LiveModel *model = self.list[indexPath.item];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
    [imageView sd_setImageWithURL:[NSURL URLWithString:model.smallpic] placeholderImage:[UIImage imageNamed:@"lookup"]];
    [cell.contentView addSubview:imageView];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PLPlayerViewController *controller = [[PLPlayerViewController alloc] init];
    controller.live = self.list[indexPath.item];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
