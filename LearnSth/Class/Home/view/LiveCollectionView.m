//
//  LiveCollectionView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/6/12.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "LiveCollectionView.h"
#import "LiveCollectionCell.h"
#import "BannerScrollView.h"

#import "BannerModel.h"
#import "LiveModel.h"

#import "UIScrollView+Empty.h"
#import "UIView+Tool.h"
#import "HttpManager.h"

#import "Aspects.h"
#import <MJRefresh/MJRefresh.h>

@interface LiveCollectionView () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) BannerScrollView *bannerScrollView;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *bannerList;
@property (nonatomic, strong) NSMutableArray *liveList;

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL noMoreData;
@property (nonatomic, assign) BOOL refreshing;

@end

static NSString *const identifier = @"Cell";
static NSString *const headerIdentifier = @"headerCell";
static const NSInteger liveColumn = 2;//多少列
static const NSInteger itemPerPage = 20;//每页个数
static const CGFloat threshold = 0.7;//预加载

@implementation LiveCollectionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.page = 1;
        
        [self addSubview:self.collectionView];
        [self loadBannerData];
        [self refreshLiveData];
        
//        [self loadData];//dispatch_group_t用法
        
        __weak typeof(self) weakSelf = self;
        [weakSelf.collectionView aspect_hookSelector:@selector(reloadData) withOptions:AspectPositionBefore usingBlock:^{
            [weakSelf.collectionView checkEmpty];
        } error:NULL];
    }
    return self;
}

- (void)viewWillShow:(BOOL)flag {
    if (flag) {
        [self.bannerScrollView openTimer];
    } else {
        [self.bannerScrollView invalidateTimer];
    }
}

- (void)loadBannerData {
    [[HttpManager shareManager] getAdBannerListCompletion:^(NSArray *list, NSError *error) {
        if (!error) {
            self.bannerList = [BannerModel bannerWithArray:list];
        } else {
            self.bannerList = [BannerModel bannerWithCacheArray];
        }
        
        NSMutableArray *imageStringArray = [NSMutableArray arrayWithCapacity:_bannerList.count];
        [self.bannerList enumerateObjectsUsingBlock:^(BannerModel * obj, NSUInteger idx, BOOL * stop) {
            [imageStringArray addObject:obj.imageUrl];
        }];
        
        self.bannerScrollView.imageArray = [NSArray arrayWithArray:imageStringArray];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        
        [BannerModel cacheWithBanners:self.bannerList];
    }];
}

- (void)refreshLiveData {
    self.refreshing = YES;
    
    NSDictionary *param = @{@"page":@(self.page)};
    [[HttpManager shareManager] getHotLiveListWithParam:param completion:^(NSArray *list, NSError *error) {
        [self.collectionView.mj_header endRefreshing];

        if (error) {
            [self showErrorWithError:error];
            if (self.page > 1) {
                self.page--;
            }
        } else {
            if (self.page == 1) {
                self.liveList = [NSMutableArray arrayWithArray:[LiveModel liveWithArray:list]];
            } else {
                [self.liveList addObjectsFromArray:[LiveModel liveWithArray:list]];
            }
            
            if (list.count < itemPerPage) {
                self.noMoreData = YES;
            }
            [self.collectionView reloadData];
        }
        
        self.refreshing = NO;
        [self.collectionView checkEmpty];
    }];
}

/**
 * 2个数据都加载完，才reload
 */
//- (void)loadData {
//    dispatch_group_t group = dispatch_group_create();
//    dispatch_queue_t serialQueue = dispatch_queue_create("com.test.www", DISPATCH_QUEUE_CONCURRENT);
//
//    dispatch_group_enter(group);
//    dispatch_group_async(group, serialQueue, ^{
//        [[HttpManager shareManager] getAdBannerListCompletion:^(NSArray *list, NSError *error) {
//            dispatch_group_leave(group);
//
//            if (!error) {
//                self.bannerList = [BannerModel bannerWithArray:list];
//            } else {
//                self.bannerList = [BannerModel bannerWithCacheArray];
//            }
//
//            NSMutableArray *imageStringArray = [NSMutableArray arrayWithCapacity:_bannerList.count];
//            [self.bannerList enumerateObjectsUsingBlock:^(BannerModel * obj, NSUInteger idx, BOOL * stop) {
//                [imageStringArray addObject:obj.imageUrl];
//            }];
//
//            self.bannerScrollView.imageArray = imageStringArray;
//
//            [BannerModel cacheWithBanners:self.bannerList];
//        }];
//    });
//
//    dispatch_group_enter(group);
//    dispatch_group_async(group, serialQueue, ^{
//        NSDictionary *param = @{@"page":@(self.page)};
//        [[HttpManager shareManager] getHotLiveListWithParam:param completion:^(NSArray *list, NSError *error) {
//            dispatch_group_leave(group);
//
//            if (error) {
//                [self showErrorWithError:error];
//            } else {
//                self.liveList = [NSMutableArray arrayWithArray:[LiveModel liveWithArray:list]];
//            }
//        }];
//    });
//
//    dispatch_group_notify(group, serialQueue, ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.collectionView reloadData];
//        });
//    });
//}

#pragma mark
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.bannerList.count > 0) {
        return self.bannerScrollView.frame.size;
    }
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader] && self.bannerList.count > 0) {
        UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier forIndexPath:indexPath];
        
        BannerScrollView *scrollView = [reusableView viewWithTag:1111];
        if (!scrollView) {
            self.bannerScrollView.tag = 1111;
            [reusableView addSubview:self.bannerScrollView];
        }
        return reusableView;
    }
    
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.liveList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LiveCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    LiveModel *model = self.liveList[indexPath.item];
    cell.liveModel = model;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.LiveClickBlock) {
        self.LiveClickBlock(indexPath.item, self.liveList);
    }
}

//- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
//
//    for (NSIndexPath *indexPath in indexPaths) {
//        LiveCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
//
//        LiveModel *model = self.liveList[indexPath.item];
//        cell.liveModel = model;
//    }
//}

#pragma mark
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.noMoreData || self.refreshing || self.liveList.count == 0) {
        return;
    }

    CGFloat current = scrollView.contentOffset.y + scrollView.frame.size.height;
    CGFloat total = scrollView.contentSize.height;
    CGFloat ratio = current / total;

    NSInteger totalItem = itemPerPage * (_page + 1);
    CGFloat needRead = itemPerPage * threshold + self.page * itemPerPage;
    CGFloat newThreshold = needRead / totalItem;

    if (ratio >= newThreshold) {
        self.page += 1;
        [self refreshLiveData];
    }
}

#pragma mark
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat margin = 3.0;
        CGFloat viewW = CGRectGetWidth(self.frame);
        CGFloat itemWidth = (viewW - margin) / liveColumn;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0);
        flowLayout.minimumInteritemSpacing = margin;//垂直滑动时，同一行左右间距
        flowLayout.minimumLineSpacing = margin;//垂直滑动时，同一列上下间距
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                             collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_collectionView registerClass:[LiveCollectionCell class] forCellWithReuseIdentifier:identifier];
        [_collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:headerIdentifier];
        
        __weak typeof(self) weakSelf = self;
        
        _collectionView.mj_header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
            weakSelf.page = 1;
            weakSelf.noMoreData = NO;
            [weakSelf refreshLiveData];
        }];
//        _collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
//            weakSelf.page++;
//            if (weakSelf.liveList.count == 0) {
//                weakSelf.page = 1;
//            }
//            [weakSelf refreshLiveData];
//        }];
        
        _collectionView.clickBlock = ^{
            weakSelf.page = 1;
            weakSelf.noMoreData = NO;
            [weakSelf refreshLiveData];
        };
        
        MJRefreshGifHeader *gifHeader = (MJRefreshGifHeader *)_collectionView.mj_header;
        
        NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:29];
        for (NSInteger i = 137; i < 166; i++) {
            NSString *imageName = [NSString stringWithFormat:@"loading_00%ld",i];
            
            [imageArray addObject:[UIImage imageNamed:imageName]];
        }
        [gifHeader setImages:imageArray duration:0.6 forState:MJRefreshStatePulling];
        [gifHeader setImages:imageArray duration:0.6 forState:MJRefreshStateRefreshing];
        
        gifHeader.lastUpdatedTimeLabel.hidden = YES;
        gifHeader.stateLabel.hidden = YES;
    }
    
    return _collectionView;
}

- (BannerScrollView *)bannerScrollView {
    if (!_bannerScrollView) {
        CGFloat viewW = CGRectGetWidth(self.frame);
        _bannerScrollView = [[BannerScrollView alloc] initWithFrame:CGRectMake(0, 0, viewW, viewW * 0.24)];
        
        __weak typeof(self) weakSelf = self;
        _bannerScrollView.ImageClickBlock = ^(NSInteger index) {
            BannerModel *model = weakSelf.bannerList[index];
            if (model.link.length > 0 && weakSelf.BannerClickBlock) {
                weakSelf.BannerClickBlock(model.link,model.title);
            }
        };
    }
    
    return _bannerScrollView;
}

@end
