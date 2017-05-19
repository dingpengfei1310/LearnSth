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
#import "AddressDataSource.h"

@interface ProvinceViewController ()<UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) AddressDataSource *dataSource;
@property (nonatomic, strong) NSArray *provinces;

@end

@implementation ProvinceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"地区";
    
    self.searchController.searchBar.backgroundImage = [CustomiseTool imageWithColor:[UIColor clearColor]];
    CellInfoBlock block = ^(UITableViewCell *cell,NSDictionary *info){
        cell.textLabel.text = info[@"name"];
    };
    _dataSource = [[AddressDataSource alloc] initWithDatas:self.provinces
                                                identifier:@"cell"
                                                 cellBlock:block];
    
    self.tableView.dataSource = _dataSource;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

#pragma mark
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *province = self.provinces[indexPath.row];

    CityViewController *cityVC = [[CityViewController alloc] initWithStyle:UITableViewStyleGrouped];
    cityVC.province = province;
    [self.navigationController pushViewController:cityVC animated:YES];
}

#pragma mark
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (searchController.searchBar.text.length > 0) {
        SearchResultController *controller = (SearchResultController *)self.searchController.searchResultsController;
        NSString *text = searchController.searchBar.text;
        controller.dataArray = [[SQLManager manager] searchResultWith:text];
    }
}

#pragma mark
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
}

@end
