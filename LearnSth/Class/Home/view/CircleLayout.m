//
//  CircleLayout.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/12/29.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "CircleLayout.h"

@interface CircleLayout ()

@property (nonatomic, assign) CGFloat radius;//半径
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGFloat anglePer;//最小角度

@property (nonatomic, strong) NSMutableArray *allAttributeArray;

@end;

@implementation CircleLayout

- (instancetype)init {
    if (self = [super init]) {
        self.allAttributeArray = [NSMutableArray array];
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    [self.allAttributeArray removeAllObjects];
    NSUInteger cellCount = [self.collectionView numberOfItemsInSection:0];
    if (cellCount == 0) {
        return;
    }
    
    CGSize viewSize = self.collectionView.frame.size;
    _radius = viewSize.height * 3;
    _itemSize = CGSizeMake(120, 200);
    _anglePer = atan(_itemSize.width / _radius);
    
    /*获取总的旋转的角度*/
    CGFloat angleTotal = (cellCount - 1) * self.anglePer;
    /*随着UICollectionView的移动，第0个cell初始时的角度*/
    CGFloat angleFirst = -1 * angleTotal * self.collectionView.contentOffset.x / (self.collectionView.contentSize.width - viewSize.width);
//    CGFloat angleFirst = -M_PI_4;
    CGFloat centerX = self.collectionView.contentOffset.x + CGRectGetWidth(self.collectionView.bounds) / 2.0;
    CGFloat centerY = viewSize.height * 0.5;
    NSLog(@"centerX:%f---",self.collectionView.contentOffset.x);
    
//    /*锚点的位置*/
//    CGFloat anchorPointY = (_itemSize.height / 2.0 + self.radius) / _itemSize.height;
//    NSLog(@"anchorPointY:%f",anchorPointY);
//    NSLog(@"centerX:%f---",centerX);
    
    for (int i = 0; i < cellCount; i++) {
        UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        
        CGFloat ang = angleFirst + _anglePer * i;
        
        
//        attribute.anchorPoint = CGPointMake(0.5, anchorPointY);
        attribute.size = self.itemSize;
        attribute.center = CGPointMake(centerX + sin(_anglePer * i) * (_radius), centerY + ((_radius) * 0.5 * (1 - cos(_anglePer * i))));
//        NSLog(@"centerX:%f---",centerX + sin(_anglePer * i) * (_radius));
        attribute.transform = CGAffineTransformMakeRotation(ang);
//        attribute.zIndex = (int)(-1) *i *1000;
        [self.allAttributeArray addObject:attribute];
    }
}

- (CGSize)collectionViewContentSize {
    NSUInteger cellCount = [self.collectionView numberOfItemsInSection:0];
    return CGSizeMake(cellCount * _itemSize.width, CGRectGetHeight(self.collectionView.bounds));
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
//    NSMutableArray* attributes = [NSMutableArray array];
//    for (NSInteger i = 0 ; i < self.cellCount; i++) {
//        //这里利用了-layoutAttributesForItemAtIndexPath:来获取attributes
//        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
//        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
//    }
//    return attributes;
    
    return self.allAttributeArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
//    attributes.size = CGSizeMake(ITEM_SIZE, ITEM_SIZE);
//    attributes.center = CGPointMake(_center.x + _radius * cosf(2 * path.item * M_PI / _cellCount), _center.y + _radius * sinf(2 * path.item * M_PI / _cellCount));
    
    
//    attributes.size = _itemSize;
//    attributes.center = CGPointMake(_center.x + _radius * cosf(indexPath.item * (M_PI / 6.0) - M_PI_2), _center.y + _radius * sinf(indexPath.item * (M_PI / 6.0) - M_PI_2));
    
//    WheelCollectionLayoutAttributes *attribute = [WheelCollectionLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
//    attribute.anchorPoint = CGPointMake(0.5, anchorPointY);
//    attributes.size = self.itemSize;
//    attributes.center = CGPointMake(self.collectionView.contentOffset.x + CGRectGetWidth(self.collectionView.bounds)/2.0, CGRectGetMidY(self.collectionView.bounds));
//    attributes.angle = angle + self.anglePerItem *i;
//    attributes.transform = CGAffineTransformMakeRotation(attribute.angle);
//    attributes.zIndex = (int)(-1) *i *1000;
    
    
//    return attributes;
    return self.allAttributeArray[indexPath.item];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
