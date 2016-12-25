//
//  PopoverViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/26.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "PopoverViewController.h"

@interface PopoverViewController () <UITableViewDataSource,UITableViewDelegate>{
    CGFloat viewWidth;
    CGFloat ViewHeight;
}

@property (nonatomic, strong) UITableView *tableView;

@end

static NSString *identifier = @"cell";

@implementation PopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.preferredContentSize = CGSizeMake(80, self.dataArray.count * 50);
    
    viewWidth = CGRectGetWidth(self.view.bounds);
    ViewHeight = CGRectGetHeight(self.view.bounds);
    self.tableView.frame = CGRectMake(0, 0, viewWidth, ViewHeight);
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    [cell.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49, viewWidth, 0.5)];
    lineView.backgroundColor = KBackgroundColor;
    [cell.contentView addSubview:lineView];
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.SelectIndex(indexPath.row);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.scrollEnabled = NO;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 50;
    }
    
    return _tableView;
}

- (UIPopoverPresentationController *)popover {
    if (!_popover) {
        _popover = self.popoverPresentationController;
        _popover.backgroundColor = [UIColor whiteColor];
        _popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }
    
    return _popover;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
