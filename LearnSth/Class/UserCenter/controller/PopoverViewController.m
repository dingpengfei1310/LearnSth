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
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 50;
    [self.view addSubview:_tableView];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    viewWidth = CGRectGetWidth(self.view.frame);
    ViewHeight = CGRectGetHeight(self.view.frame);
    
    _tableView.frame = CGRectMake(0, 0, viewWidth, ViewHeight);
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(controller:didSelectAtIndex:)]) {
        [self.delegate controller:self didSelectAtIndex:indexPath.row];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
