//
//  ProvinceViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/26.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "ProvinceViewController.h"
#import "CityViewController.h"
#import "SearchResultController.h"

#import "SQLManager.h"

@interface ProvinceViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *provinces;

@end

@implementation ProvinceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.searchBar.backgroundImage = [UIImage imageWithColor:[UIColor clearColor]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.provinces.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"provinceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *province = self.provinces[indexPath.row];
    cell.textLabel.text = province[@"name"];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"全部";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *province = self.provinces[indexPath.row];

    CityViewController *cityVC = [[CityViewController alloc]init];
    cityVC.province = province;
    [self.navigationController pushViewController:cityVC animated:YES];
}

#pragma mark

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (searchController.searchBar.text.length > 0) {
        SearchResultController *controller = (SearchResultController *)self.searchController.searchResultsController;
        controller.dataArray = [[SQLManager manager] searchResultWith:searchController.searchBar.text];
    }
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

- (NSArray *)provinces {
    if (!_provinces) {
        _provinces = [[SQLManager manager] getProvinces];
    }
    return _provinces;
}

- (UISearchController *)searchController {
    if (!_searchController) {
        SearchResultController *resultController = [[SearchResultController alloc] init];
        _searchController = [[UISearchController alloc] initWithSearchResultsController:resultController];
        _searchController.searchResultsUpdater = self;
//        _searchController.dimsBackgroundDuringPresentation = NO;
//        _searchController.obscuresBackgroundDuringPresentation = NO;
//        _searchController.hidesNavigationBarDuringPresentation = NO;
    }
    
    return _searchController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
