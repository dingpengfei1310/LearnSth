//
//  CityViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/26.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "CityViewController.h"

#import "SQLManager.h"
#import "UserModel.h"
#import "Utils.h"

#import "AddressDataSource.h"

@interface CityViewController ()

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) AddressDataSource *dataSource;

@end

@implementation CityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"地区";
    
    CellInfoBlock block = ^(UITableViewCell *cell,NSDictionary *info){
        cell.textLabel.text = info[@"name"];
    };
    _dataSource = [[AddressDataSource alloc] initWithDatas:self.dataArray
                                                identifier:@"cell"
                                                 cellBlock:block];
    
    self.tableView.dataSource = _dataSource;
}

#pragma mark
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *city = self.dataArray[indexPath.row];
    [UserModel userManager].province = self.province[@"name"];
    [UserModel userManager].city = city[@"name"];
    [Utils setUserModel:[UserModel userManager]];
    
    NSInteger index = self.navigationController.viewControllers.count - 3;
    if (index >= 0) {
        UIViewController *controller = self.navigationController.viewControllers[index];
        [self.navigationController popToViewController:controller animated:YES];
    }
}

#pragma mark
- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[SQLManager manager] getCitiesWithProvinceId:self.province[@"id"]];
    }
    return _dataArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

