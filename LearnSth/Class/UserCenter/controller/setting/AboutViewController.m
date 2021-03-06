//
//  AboutViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/10/27.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "AboutViewController.h"
#import "ShowViewController.h"
#import "FeedbackController.h"

#import "DeviceConfig.h"
#import <StoreKit/StoreKit.h>

@interface AboutViewController ()<UITableViewDataSource,UITableViewDelegate,SKStoreProductViewControllerDelegate>

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *subTitleArray;

@end

static NSString *const identifier = @"cell";

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(toAppStore)];
    
    self.titleArray = @[@"电话",@"网站",@"新功能",@"反馈"];
    self.subTitleArray = @[@"4008886666",@"www.apple.com",@"",@""];
    
    CGFloat barH = NavigationBarH + StatusBarH;
    CGRect frame = CGRectMake(0, barH, Screen_W, Screen_H - barH);
    UITableView * tableView =[[UITableView alloc]initWithFrame:frame style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = self.titleArray[indexPath.row];
    cell.detailTextLabel.text = self.subTitleArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        NSString *tel = self.subTitleArray[indexPath.row];
        NSString *telStr = [NSString stringWithFormat:@"tel:%@",tel];
        NSURL *url = [NSURL URLWithString:telStr];
        
        [[UIApplication sharedApplication] openURL:url];
        
    } else if (indexPath.row == 1) {
        UIAlertController * alertController = [UIAlertController  alertControllerWithTitle:nil message:@"是否打开网站" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *url = self.subTitleArray[indexPath.row];
            NSString *urlString = [NSString stringWithFormat:@"http:%@",url];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }];
        
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else if (indexPath.row == 2) {
        ShowViewController *showVC = [[ShowViewController alloc] init];
        showVC.DismissShowBlock = ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        [self presentViewController:showVC animated:YES completion:nil];
    } else if (indexPath.row == 3) {
        FeedbackController *controller = [[FeedbackController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 120;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat width = CGRectGetWidth(tableView.frame);
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 120)];
    headerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((width - 60) / 2, 20, 60, 60)];
    iconView.layer.masksToBounds = YES;
    iconView.layer.cornerRadius = 5;
    [headerView addSubview:iconView];
    
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 85, width, 30)];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    versionLabel.textColor = KBaseTextColor;
    [headerView addSubview:versionLabel];
    
    NSString *appVersion = [DeviceConfig getAppVersion];
    NSString *appIconName = [DeviceConfig getAppIconName];
    
    iconView.image = [UIImage imageNamed:appIconName];
    versionLabel.text = [NSString stringWithFormat:@"版本号 %@",appVersion];
    
    return headerView;
}

#pragma mark
- (void)toAppStore {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    SKStoreProductViewController *storeVC = [[SKStoreProductViewController alloc] init];
    storeVC.delegate = self;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"414478124"
                                                     forKey:SKStoreProductParameterITunesItemIdentifier];
    [self presentViewController:storeVC animated:YES completion:^{
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        [storeVC loadProductWithParameters:dict completionBlock:^(BOOL result, NSError * error) {
        }];
    }];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
