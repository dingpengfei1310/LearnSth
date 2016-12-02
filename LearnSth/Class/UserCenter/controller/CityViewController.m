//
//  CityViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/26.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "CityViewController.h"
#import "SQLManager.h"
#import "UIImage+Tool.h"

@interface CityViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *result;

@end

@implementation CityViewController

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
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.result = [[SQLManager manager] getCitiesWithProvinceId:self.province[@"id"]];
    [self.tableView reloadData];
}

#pragma mark
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.result.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"cityCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSDictionary *city = self.result[indexPath.row];
    cell.textLabel.text = city[@"name"];
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"全部";
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, ViewFrameOrigin_X, ScreenWidth, ScreenHeight - 64)
                                                 style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return _tableView;
}

- (NSArray *)result {
    if (!_result) {
        _result = [[SQLManager manager] getCitiesWithProvinceId:self.province[@"id"]];
    }
    return _result;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
