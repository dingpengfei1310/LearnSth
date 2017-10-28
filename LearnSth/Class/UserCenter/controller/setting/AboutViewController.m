//
//  AboutViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/10/27.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *subTitleArray;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.titleArray = @[@"官方电话",@"官方网站"];
    self.subTitleArray = @[@"4008886666",@"www.apple.com."];
    
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
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    }
    
    cell.textLabel.text = self.titleArray[indexPath.row];
    cell.detailTextLabel.text = self.subTitleArray[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        NSString *tel = self.subTitleArray[indexPath.row];
        NSString *telStr = [NSString stringWithFormat:@"tel:%@",tel];
        NSURL *url = [NSURL URLWithString:telStr];
        
        UIWebView *webView = [[UIWebView alloc] init];
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
        [self.view addSubview:webView];
        
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
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 120;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat width = CGRectGetWidth(tableView.frame);
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 120)];
    headerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((width - 60) / 2, 20, 60, 60)];
    iconView.layer.masksToBounds = YES;
    iconView.layer.cornerRadius = 5;
    [headerView addSubview:iconView];
    
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 85, width, 30)];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.font = [UIFont systemFontOfSize:15];
    versionLabel.textColor = [UIColor grayColor];
    [headerView addSubview:versionLabel];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *imageName = [[infoDictionary valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    
    iconView.image = [UIImage imageNamed:imageName];
    versionLabel.text = [NSString stringWithFormat:@"版本号 %@",app_Version];
    
    return headerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
