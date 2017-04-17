//
//  UserInfoViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/1.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UserInfoViewController.h"
#import "HeaderImageController.h"
#import "AddressPickerController.h"
#import "ScanQRCodeController.h"
#import "IDCardViewController.h"
#import "WebViewController.h"
#import "UserManager.h"

@interface UserInfoViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

static NSString *HeaderIdentifier = @"headerCell";
static NSString *Identifier = @"cell";

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"个人信息";
    
    self.dataArray = @[@"头像",@"名字",@"城市",@"身份证"];
    [self.view addSubview:self.tableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClick:)];
}

#pragma mark
- (void)addClick:(UIBarButtonItem *)item {
    if (TARGET_OS_SIMULATOR) {
        [self showError:@"真机使用"];
        return;
    }
    ScanQRCodeController *controller = [[ScanQRCodeController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showAlertControllerOnChangeUsername {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改昵称" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * textField) {
        textField.placeholder = @"请输入昵称";
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertAction *certainAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        UITextField *field = alert.textFields[0];
        [UserManager shareManager].username = field.text;
        [UserManager updateUser];
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    [alert addAction:cancelAction];
    [alert addAction:certainAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)presentAddressPickerController {
    AddressPickerController *controller = [[AddressPickerController alloc] init];
    controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
    controller.AddressDismissBlock = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    controller.SelectBlock = ^(NSDictionary *province,NSDictionary *city) {
        AddressModel *address = [[AddressModel alloc] init];
        address.province = province[@"name"];
        address.city = city[@"name"];
        
        [UserManager shareManager].address = address;
        [UserManager updateUser];
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    };
    [self presentViewController:controller animated:NO completion:nil];
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row ==0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HeaderIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HeaderIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = self.dataArray[indexPath.row];
        
        UIImageView *headerImageView = [cell viewWithTag:101];
        if (!headerImageView) {
            headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(Screen_W - 80, 10, 50, 50)];
            headerImageView.layer.masksToBounds = YES;
            headerImageView.layer.cornerRadius = 3;
            [cell.contentView addSubview:headerImageView];
        }
        headerImageView.image = [UserManager shareManager].headerImage;
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:Identifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.detailTextLabel.text = nil;
        cell.textLabel.text = self.dataArray[indexPath.row];
        
        if (indexPath.row == 1 && [UserManager shareManager].username) {
            cell.detailTextLabel.text = [UserManager shareManager].username;
        } else if (indexPath.row == 2 && [UserManager shareManager].address.city) {
            AddressModel *add = [UserManager shareManager].address;
            NSString *address = [NSString stringWithFormat:@"%@-%@",add.province,add.city];
            cell.detailTextLabel.text = address;
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        HeaderImageController *controller = [[HeaderImageController alloc] init];
        controller.ChangeHeaderImageBlock = ^{
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        };
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if (indexPath.row == 1) {
        [self showAlertControllerOnChangeUsername];
        
    } else if (indexPath.row == 2) {
        [self presentAddressPickerController];
        
    } else if (indexPath.row == 3) {
        if (TARGET_OS_SIMULATOR) {
            [self showError:@"真机使用"];
            return;
        }
        IDCardViewController *controller = [[IDCardViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.row == 4) {
        WebViewController *controller = [[WebViewController alloc] init];
        controller.title = @"微博";
        controller.urlString = @"http://m.weibo.cn/n/ever丶飞飞";
        //controller.urlString = @"http://m.weibo.cn/u/5277766604";
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0 ? 70 : 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Screen_W, Screen_H - 64) style:UITableViewStyleGrouped];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
