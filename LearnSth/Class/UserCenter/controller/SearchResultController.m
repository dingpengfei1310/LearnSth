//
//  SearchResultController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/14.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "SearchResultController.h"
#import "AddressDataSource.h"

@interface SearchResultController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AddressDataSource *dataSource;

@end

@implementation SearchResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    
    CellInfoBlock block = ^(UITableViewCell *cell,NSDictionary *info){
        cell.textLabel.text = info[@"name"];
    };
    _dataSource = [[AddressDataSource alloc] initWithDatas:self.dataArray
                                                identifier:@"cell"
                                                 cellBlock:block];
    self.tableView.dataSource = self.dataSource;
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, ViewFrame_X, Screen_W, Screen_H) style:UITableViewStylePlain];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.backgroundColor = KBackgroundColor;
    }
    
    return _tableView;
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    _dataSource.dataArray = dataArray;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
