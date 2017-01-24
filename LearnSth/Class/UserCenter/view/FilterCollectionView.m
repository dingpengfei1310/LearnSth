//
//  FilterCollectionView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/1/24.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "FilterCollectionView.h"
//#import "ImageFilterModel.h"

@interface FilterCollectionView ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation FilterCollectionView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.collectionView];
    }
    return self;
}

- (void)setFilters:(NSArray *)filters {
    if (_filters != filters) {
        _filters = filters;
        [self.collectionView reloadData];
    }
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filters.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    
    UILabel *contentLabel = [cell.contentView viewWithTag:100];
    if (!contentLabel) {
        contentLabel = [[UILabel alloc] initWithFrame:cell.bounds];
        contentLabel.tag = 100;
        contentLabel.numberOfLines = 0;
        contentLabel.textAlignment = NSTextAlignmentCenter;
        contentLabel.font = [UIFont boldSystemFontOfSize:15];
        [cell.contentView addSubview:contentLabel];
    }
    
    NSDictionary *filterInfo = self.filters[indexPath.item];
    contentLabel.text = filterInfo[@"name"];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.FilterSelect) {
        self.FilterSelect(indexPath.item);
    }
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat itemWidth = self.frame.size.height;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
        flowLayout.minimumInteritemSpacing = 5;
//        flowLayout.minimumLineSpacing = interitemSpacing;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                             collectionViewLayout:flowLayout];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}

@end

