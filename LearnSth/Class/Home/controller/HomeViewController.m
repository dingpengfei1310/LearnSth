//
//  ViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "HomeViewController.h"
#import "WebViewController.h"
#import "PLPlayerViewController.h"
#import "DownloadViewController.h"

#import "BannerScrollView.h"
#import "LiveCollectionCell.h"
#import "UICollectionView+Tool.h"
#import "ADModel.h"
#import "LiveModel.h"

#import "Aspects.h"
#import "MJRefresh.h"

#import "SRWebSocket.h"
#import "DanMuView.h"
#import "DanMuModel.h"

@interface HomeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,SRWebSocketDelegate>

@property (nonatomic, strong) NSArray *bannerList;
@property (nonatomic, strong) BannerScrollView *bannerScrollView;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *liveList;
@property (nonatomic, assign) NSInteger page;

@property (nonatomic, strong) SRWebSocket *webSocket;
@property (nonatomic, strong) DanMuView *danMuView;

@end

const NSInteger liveColumn = 2;
static NSString *reuseIdentifier = @"cell";
static NSString *headerReuseIdentifier = @"headerCell";

@implementation HomeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = @"🍎";
    self.page = 1;
    [self.view addSubview:self.collectionView];
    
    [self navigationBackItem];
    [self getHomeAdBanner];
//    [self refreshLiveData];
    
//    _danMuView = [[DanMuView alloc] init];
//    [self.view addSubview:_danMuView];
    
//    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    [window addSubview:_danMuView];
//    [self.webSocket open];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.bannerScrollView setUpTimer];
    [self.collectionView aspect_hookSelector:@selector(reloadData) withOptions:AspectPositionBefore usingBlock:^{
        [self.collectionView checkEmpty];
    } error:NULL];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.bannerScrollView invalidateTimer];
}

- (void)navigationBackItem {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"00" style:UIBarButtonItemStylePlain target:self action:@selector(homeRightItemClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}

#pragma mark
- (void)getHomeAdBanner {
    [[HttpManager shareManager] getAdBannerListCompletion:^(NSArray *list, NSError *error) {
        if (!error) {
            NSArray *adArray = [ADModel adWithArray:list];
            
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orderid > 2"];
//            self.bannerList = [adArray filteredArrayUsingPredicate:predicate];
            self.bannerList = [[NSArray alloc] initWithArray:adArray copyItems:YES];;
            
            NSMutableArray *imageStringArray = [NSMutableArray arrayWithCapacity:self.bannerList.count];
            [self.bannerList enumerateObjectsUsingBlock:^(ADModel * obj, NSUInteger idx, BOOL * stop) {
                [imageStringArray addObject:obj.imageUrl];
            }];
            
            [self.bannerScrollView setImageArray:imageStringArray];
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        }
    }];
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

- (void)homeRightItemClick {
//    self.collectionView.hidden = !self.collectionView.hidden;
    
//    DownloadViewController *controller = [[DownloadViewController alloc] init];
//    controller.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:controller animated:YES];
    
//    NSArray *array = @[@"我是个弹幕",
//                       @"我也是个弹幕",
//                       @"你是什么鬼",
//                       @"我是个长弹幕我是个长弹幕",
//                       @"我好方",
//                       @"我是个弹幕",
//                       @"我也是个弹幕",
//                       @"你是什么鬼",
//                       @"我是个长弹幕我是个长弹幕我是个长弹幕",
//                       @"我好方"];
//    
//    NSArray *colorArray = @[[UIColor redColor],
//                            [UIColor greenColor],
//                            [UIColor blackColor],
//                            [UIColor blueColor]];
//    
//    for (int i = 0; i < array.count; i++) {
//        DanMuModel *model = [[DanMuModel alloc] init];
//        model.text = array[i];
//        model.position = i % 3;
//        model.textColor = colorArray[i % 4];
//        _danMuView.model = model;
//    }
    
    if (self.webSocket.readyState == SR_OPEN) {
        [self.webSocket send:@"我是Socket😄"];
    }
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
    PLPlayerViewController *controller = [[PLPlayerViewController alloc] init];
    controller.PlayerDismissBlock = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    controller.index = indexPath.item;
    controller.liveArray = self.liveList;
//    controller.live = self.liveList[indexPath.item];
    controller.hidesBottomBarWhenPushed = YES;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:nvc animated:YES completion:nil];
}

#pragma mark - SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"webSocketDidOpen");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError:%@",error);
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if (message) {
        DanMuModel *model = [[DanMuModel alloc] init];
        model.text = message;
        model.position = 2;
        _danMuView.model = model;
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"didCloseWithCode");
}

#pragma mark
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat itemWidth = (Screen_W - (liveColumn + 1) * 10) / liveColumn;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        
        CGRect collectionViewRect = CGRectMake(0, 0, Screen_W, Screen_H);
        _collectionView = [[UICollectionView alloc] initWithFrame:collectionViewRect
                                             collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        [_collectionView registerClass:[LiveCollectionCell class] forCellWithReuseIdentifier:reuseIdentifier];
        [_collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:headerReuseIdentifier];
        
        _collectionView.mj_header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
            self.page = 1;
            [self refreshLiveData];
        }];
        _collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            self.page++;
            [self refreshLiveData];
        }];
        
        __weak typeof(self) weakSelf = self;
        [_collectionView setClickBlock:^{
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
        _bannerScrollView = [[BannerScrollView alloc] initWithFrame:CGRectMake(0, 0, Screen_W, Screen_W * 0.24)];
        
        __weak typeof(self) weakSelf = self;
        _bannerScrollView.imageClickBlock = ^(NSInteger index) {
            
            ADModel *model = weakSelf.bannerList[index];
            if (model.link.length > 0) {
                WebViewController *controller = [[WebViewController alloc] init];
                controller.hidesBottomBarWhenPushed = YES;
                controller.title = model.title;
                controller.urlString = model.link;
                [weakSelf.navigationController pushViewController:controller animated:YES];
            }
        };
    }
    
    return _bannerScrollView;
}

- (SRWebSocket *)webSocket {
    if (!_webSocket) {
        NSString *urlString = @"ws://192.168.1.119:8080/jeesns/test/3/2";
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:url];
        requestM.timeoutInterval = 15;
        
        _webSocket = [[SRWebSocket alloc] initWithURLRequest:requestM];
        _webSocket.delegate = self;
    }
    return _webSocket;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
