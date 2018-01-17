//
//  InkeViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/12/22.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "InkeViewController.h"
#import "PLPlayerViewController.h"
#import "LiveCollectionCell.h"
#import "LiveModel.h"

@interface InkeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataArray;

@end

static NSString * const identifier = @"cell";

@implementation InkeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Live";
    
    [self.view addSubview:self.collectionView];
    [[HttpManager shareManager] getInKeLiveListCompletion:^(NSArray *list, NSError *error) {
        self.dataArray = [LiveModel liveWithArray:list];
        [self.collectionView reloadData];
    }];
}

#pragma mark
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LiveCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    LiveModel *model = self.dataArray[indexPath.item];
    cell.liveModel = model;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PLPlayerViewController *controller = [[PLPlayerViewController alloc] init];
    controller.PlayerDismissBlock = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    controller.index = indexPath.row;
    controller.liveArray = self.dataArray;
    controller.hidesBottomBarWhenPushed = YES;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:nvc animated:YES completion:nil];
}

#pragma mark
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat margin = 3.0;
        CGFloat viewW = CGRectGetWidth(self.view.frame);
        CGFloat itemWidth = (viewW - margin) / 2;
        
        CGFloat barH = NavigationBarH + StatusBarH;
        CGRect frame = CGRectMake(0, barH, Screen_W, Screen_H - barH);
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0);
        flowLayout.minimumInteritemSpacing = margin;//垂直滑动时，同一行左右间距
        flowLayout.minimumLineSpacing = margin;//垂直滑动时，同一列上下间距
        
        _collectionView = [[UICollectionView alloc] initWithFrame:frame
                                             collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = KBackgroundColor;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_collectionView registerClass:[LiveCollectionCell class] forCellWithReuseIdentifier:identifier];
    }
    
    return _collectionView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
