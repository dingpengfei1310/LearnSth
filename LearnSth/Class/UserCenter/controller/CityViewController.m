//
//  CityViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/26.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "CityViewController.h"
#import "SQLManager.h"

@interface CityViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *result;

@end

@implementation CityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"地区";
    
    [self.view addSubview:self.tableView];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"全部";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
