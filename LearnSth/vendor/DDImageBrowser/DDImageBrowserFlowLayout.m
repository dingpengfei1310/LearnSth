//
//  DDImageBrowserFlowLayout.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/5/15.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "DDImageBrowserFlowLayout.h"

@implementation DDImageBrowserFlowLayout

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat pageWidth = self.itemSize.width + self.minimumLineSpacing;
    
    NSInteger lastPage;
    if (velocity.x == 0) {
        lastPage = roundf(self.collectionView.contentOffset.x / pageWidth);
    } else {
        lastPage = self.collectionView.contentOffset.x / pageWidth;
        NSInteger maxPage = (self.collectionView.contentSize.width + self.minimumLineSpacing) / pageWidth - 1;
        
        lastPage = velocity.x < 0 ? lastPage : lastPage + 1;
        lastPage = MIN(MAX(lastPage, 0), maxPage);
    }
    
    return CGPointMake(lastPage * pageWidth, 0);
}

@end
