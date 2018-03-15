//
//  UIScrollView+Empty.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2018/3/15.
//  Copyright © 2018年 丁鹏飞. All rights reserved.
//

#import "UIScrollView+Empty.h"
#import <objc/runtime.h>

static char placeholderKey;
static char reloadBlockKey;

@implementation UIScrollView (Empty)

#pragma mark
- (void)checkEmpty {
    BOOL isEmpty = YES;
    
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;
        id <UITableViewDataSource> dataSource = tableView.dataSource;
        
        NSInteger sections = 1;
        if ([dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [dataSource numberOfSectionsInTableView:tableView];
        }
        for (NSInteger i = 0; i < sections; i++) {
            if ([dataSource tableView:tableView numberOfRowsInSection:i] > 0) {
                isEmpty = NO;
                break;
            }
        }
        
    } else if ([self isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        id <UICollectionViewDataSource> dataSource = collectionView.dataSource;
        
        NSInteger sections = 1;
        if ([dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            sections = [dataSource numberOfSectionsInCollectionView:collectionView];
        }
        
        for (NSInteger i = 0; i < sections; i++) {
            if ([dataSource collectionView:collectionView numberOfItemsInSection:i] > 0) {
                isEmpty = NO;
                break;
            }
        }
        
    }
    
    isEmpty ? [self showEmptyView] : [self hideEmptyView];
}

- (void)showEmptyView {
    if (![self placeholderView]) {
        [self createPlaceHolderView];
        [self addSubview:[self placeholderView]];
    }
    [self placeholderView].hidden = NO;
}

- (void)hideEmptyView {
    [self placeholderView].hidden = YES;
}

#pragma mark
- (UIView *)placeholderView {
    return objc_getAssociatedObject(self, &placeholderKey);
}

- (void)setPlaceholderView:(UIView *)placeholderView {
    objc_setAssociatedObject(self, &placeholderKey, placeholderView, OBJC_ASSOCIATION_RETAIN);
}

- (ReloadClickBlock)clickBlock {
    return objc_getAssociatedObject(self, &reloadBlockKey);
}

- (void)setClickBlock:(ReloadClickBlock)clickBlock {
    objc_setAssociatedObject(self, &reloadBlockKey, clickBlock, OBJC_ASSOCIATION_COPY);
}

#pragma mark
- (void)createPlaceHolderView {
    UIView *placeholderView = [[UIView alloc] initWithFrame:self.bounds];
    placeholderView.backgroundColor = self.backgroundColor;
    [self setPlaceholderView:placeholderView];
    
    CGFloat buttonW = 100;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.bounds = CGRectMake(0, 0, buttonW, buttonW);
    button.center = placeholderView.center;
    [button setTitle:@"暂无内容\n点击重新加载" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button addTarget:self action:@selector(reloadClick) forControlEvents:UIControlEventTouchUpInside];
    [placeholderView addSubview:button];
}

- (void)reloadClick {
    if ([self clickBlock]) {
        ReloadClickBlock clickBlock = [self clickBlock];
        clickBlock();
    }
}

@end
