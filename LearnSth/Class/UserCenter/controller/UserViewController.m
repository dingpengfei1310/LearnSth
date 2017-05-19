//
//  UserViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UserViewController.h"
#import "PhotoLiarbraryController.h"
#import "LoginViewController.h"
#import "UserInfoViewController.h"
#import "SettingViewController.h"
#import "StepCountViewController.h"

#import "HeaderImageViewCell.h"
#import "UserManager.h"

@interface UserViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

static NSString *HeaderIdentifier = @"headerCell";
static NSString *Identifier = @"cell";

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"🏓";
    
    self.dataArray = @[@[@"头像"],
                       @[@"相册",@"步数"],
                       @[@"设置"]
                       ];
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
    
}

#pragma mark
- (void)loginClick {
    if ([CustomiseTool isLogin]) {
        UserInfoViewController *controller = [[UserInfoViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        controller.ChangeHeaderImageBlock = ^{
            [self reloadHeaderCell];
        };
        controller.ChangeUsernameBlock = ^{
            [self reloadHeaderCell];
        };
        [self.navigationController pushViewController:controller animated:YES];
        
    } else {
        LoginViewController *controller = [[LoginViewController alloc] init];
        controller.DismissBlock = ^ {
            [self reloadHeaderCell];
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:nvc animated:YES completion:nil];
    }
}

//刷新头像cell
- (void)reloadHeaderCell {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.dataArray[section];
    return array.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setSeparatorInset:UIEdgeInsetsZero];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        HeaderImageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HeaderIdentifier];
        if (!cell) {
            cell = [[HeaderImageViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HeaderIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        cell.userModel = [UserManager shareManager];
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:Identifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        NSArray *array = self.dataArray[indexPath.section];
        cell.textLabel.text = array[indexPath.row];
        
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? 70 : 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [self loginClick];
        
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            PhotoLiarbraryController *controller = [[PhotoLiarbraryController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];
            
        } else if (indexPath.row == 1) {
            StepCountViewController *controller = [[StepCountViewController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
        
    } else if (indexPath.section == 2) {
        SettingViewController *controller = [[SettingViewController alloc] init];
        controller.LogoutBlock = ^{
            [self reloadHeaderCell];
        };
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64) style:UITableViewStyleGrouped];
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
