//
//  FilterCollectionView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/1/24.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "FilterCollectionView.h"

@interface FilterCollectionView ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *filters;

@end

static NSString *ReuseIdentifier = @"cell";

@implementation FilterCollectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectZero]) {
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame filters:(NSArray *)filters {
    if (filters.count == 0) {
        return [self initWithFrame:CGRectZero];
    } else if (self = [super initWithFrame:frame]) {
        _filters = filters;
        
        CGFloat itemWidth = self.frame.size.height;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
        flowLayout.minimumInteritemSpacing = 5;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                                              collectionViewLayout:flowLayout];
        collectionView.showsHorizontalScrollIndicator = NO;
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        
        [self addSubview:collectionView];
    }
    return self;
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filters.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ReuseIdentifier forIndexPath:indexPath];
    
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    cell.selectedBackgroundView = backgroundView;
    
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

@end
