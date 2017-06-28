//
//  LiveCollectionView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/6/12.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "LiveCollectionView.h"
#import "BannerScrollView.h"
#import "LiveCollectionCell.h"

#import "BannerModel.h"
#import "LiveModel.h"

#import "UICollectionView+Tool.h"
#import "UIView+Tool.h"

#import "MJRefresh.h"
#import "HttpManager.h"

@interface LiveCollectionView () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) BannerScrollView *bannerScrollView;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *bannerList;
@property (nonatomic, strong) NSMutableArray *liveList;

@property (nonatomic, assign) NSInteger page;

@end

static NSString *reuseIdentifier = @"cell";
static NSString *headerReuseIdentifier = @"headerCell";
const  NSInteger liveColumn = 2;

@implementation LiveCollectionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.page = 1;
        
        [self addSubview:self.collectionView];
        [self loadData];
        
//        __weak typeof(self) weakSelf = self;
//        [self.collectionView aspect_hookSelector:@selector(reloadData) withOptions:AspectPositionBefore usingBlock:^{
//            [weakSelf.collectionView checkEmpty];
//        } error:NULL];
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

- (void)loadData {
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
        
        self.bannerScrollView.imageArray = imageStringArray;
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        
        [BannerModel cacheWithBanners:self.bannerList];
    }];
    
//    [self refreshLiveData];
}

- (void)refreshLiveData {
    NSDictionary *params = @{@"page":[@(self.page) stringValue]};
    [[HttpManager shareManager] getHotLiveListWithParamers:params completion:^(NSArray *list, NSError *error) {
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];

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
        }
        [self.collectionView reloadData];
    }];
}

#pragma mark
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.bannerList.count > 0) {
        return self.bannerScrollView.frame.size;
    }
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader] && self.bannerList.count > 0) {
        UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerReuseIdentifier forIndexPath:indexPath];
        
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
    LiveCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    LiveModel *model = self.liveList[indexPath.item];
    cell.liveModel = model;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.LiveClickBlock) {
        self.LiveClickBlock(indexPath.item, self.liveList);
    }
}

#pragma mark
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat viewW = CGRectGetWidth(self.frame);
        CGFloat itemWidth = (viewW - (liveColumn + 1) * 10) / liveColumn;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth + 21);//21是Text高度
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                             collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        [_collectionView registerClass:[LiveCollectionCell class] forCellWithReuseIdentifier:reuseIdentifier];
        [_collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:headerReuseIdentifier];
        
        __weak typeof(self) weakSelf = self;
        
        _collectionView.mj_header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
            weakSelf.page = 1;
            [weakSelf refreshLiveData];
        }];
        _collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            weakSelf.page++;
            if (weakSelf.liveList.count == 0) {
                weakSelf.page = 1;
            }
            [weakSelf refreshLiveData];
        }];
        
        MJRefreshGifHeader *gifHeader = (MJRefreshGifHeader *)_collectionView.mj_header;
        NSArray *images = @[[UIImage imageNamed:@"reflesh1"],
                            [UIImage imageNamed:@"reflesh2"],
                            [UIImage imageNamed:@"reflesh3"]];
        [gifHeader setImages:images forState:MJRefreshStatePulling];
        [gifHeader setImages:images forState:MJRefreshStateRefreshing];
        
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
                weakSelf.BannerClickBlock(model.link);
            }
        };
    }
    
    return _bannerScrollView;
}

@end
