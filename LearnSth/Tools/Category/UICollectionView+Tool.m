//
//  UICollectionView+Tool.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/5.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UICollectionView+Tool.h"
#import <objc/runtime.h>

static char placeHolderKey;
static char reloadBlockKey;

@implementation UICollectionView (Tool) 
//+ (void)load {
//    Method reloadData = class_getInstanceMethod([UICollectionView class], @selector(reloadData));
//    Method dd_reloadData = class_getInstanceMethod([UICollectionView class], @selector(dd_reloadData));
//    
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        method_exchangeImplementations(reloadData, dd_reloadData);
//    });
//}
//
//- (void)dd_reloadData {
//    [self checkEmpty];
//    [self dd_reloadData];
//}

#pragma mark
- (void)checkEmpty {
    id <UICollectionViewDataSource> dataSource = self.dataSource;
    
    NSInteger sections = 1;
    if ([dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
        sections = [dataSource numberOfSectionsInCollectionView:self];
    }
    
    for (NSInteger i = 0; i < sections; i++) {
        if ([dataSource collectionView:self numberOfItemsInSection:i] > 0) {
            [self hideEmptyView];
            return;
        }
    }
    
    [self showEmptyView];
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
    return objc_getAssociatedObject(self, &placeHolderKey);
}

- (void)setPlaceholderView:(UIView *)placeholderView {
    objc_setAssociatedObject(self, &placeHolderKey, placeholderView, OBJC_ASSOCIATION_RETAIN);
}

- (ReloadClickBlock)clickBlock {
    return objc_getAssociatedObject(self, &reloadBlockKey);
}

- (void)setClickBlock:(ReloadClickBlock)clickBlock {
    objc_setAssociatedObject(self, &reloadBlockKey, clickBlock, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark
- (void)createPlaceHolderView {
    CGFloat viewWidth = self.frame.size.width;
    CGFloat ViewHeight = self.frame.size.height;
    
    UIView *placeholderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, ViewHeight)];
    placeholderView.backgroundColor = self.backgroundColor;
    [self setPlaceholderView:placeholderView];
    
    CGFloat buttonW = 100;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake((viewWidth - buttonW) / 2, ViewHeight * 0.3, buttonW, buttonW);
    [button setTitle:@"暂无内容\n点击重新加载" forState:UIControlStateNormal];
    [button setTitleColor:KBaseTextColor forState:UIControlStateNormal];
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
