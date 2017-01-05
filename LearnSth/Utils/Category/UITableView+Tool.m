//
//  UITableView+Tool.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/5.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UITableView+Tool.h"
#import <objc/runtime.h>

static char placeHolderKey;
static char reloadBlockKey;

@implementation UITableView (Tool)

//+ (void)load {
//    Method reloadData = class_getInstanceMethod([UITableView class], @selector(reloadData));
//    Method dd_reloadData = class_getInstanceMethod([UITableView class], @selector(dd_reloadData));
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
    BOOL isEmpty = YES;
    id <UITableViewDataSource> dataSource = self.dataSource;
    
    NSInteger sections = 1;
    if ([dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        sections = [dataSource numberOfSectionsInTableView:self];
    }
    for (NSInteger i = 0; i < sections; i++) {
        if ([dataSource tableView:self numberOfRowsInSection:i]) {
            isEmpty = NO;
        }
    }
    
    if (isEmpty) {
        [self showEmptyView];
    } else {
        [self hideEmptyView];
    }
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
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, ViewHeight * 0.5 - 30, viewWidth, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"暂无数据，点击重新加载";
    [placeholderView addSubview:label];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureClick)];
    [placeholderView addGestureRecognizer:tapGesture];
}

- (void)gestureClick {
    if ([self clickBlock]) {
        ReloadClickBlock clickBlock = [self clickBlock];
        clickBlock();
    }
}

@end

