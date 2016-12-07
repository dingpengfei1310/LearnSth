//
//  SearchAddressController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/7.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "SearchAddressController.h"
#import "SQLManager.h"

@interface SearchAddressController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *result;

@end

@implementation SearchAddressController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"地区";
    
    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.searchBar.backgroundImage = [UIImage imageWithColor:[UIColor clearColor]];
    self.searchController.searchBar.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.searchController.active) {
        self.searchController.active = NO;
    }
}

#pragma mark UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.result = [[SQLManager manager] searchResultWith:searchBar.text];
    [self.tableView reloadData];
    
    self.searchController.active = NO;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    searchBar.tintColor = KBaseTextColor;
    return YES;
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.result.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"cityCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSDictionary *city = self.result[indexPath.row];
    cell.textLabel.text = city[@"name"];
    
    return cell;
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, ViewFrameOrigin_X, ScreenWidth, ScreenHeight - 64)
                                                 style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.backgroundColor = KBackgroundColor;
    }
    
    return _tableView;
}

- (UISearchController *)searchController {
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.dimsBackgroundDuringPresentation = NO;
        _searchController.obscuresBackgroundDuringPresentation = NO;
        _searchController.hidesNavigationBarDuringPresentation = NO;
    }
    
    return _searchController;
}


@end
