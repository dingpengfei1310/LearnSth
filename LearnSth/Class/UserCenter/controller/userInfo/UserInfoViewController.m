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
#import "UserQRCodeController.h"
#import "InkeViewController.h"

#import "HttpConnection.h"
#import "UserManager.h"
#import "AnimatedTransitioning.h"

#import <NSData+ImageContentType.h>
#import <FLAnimatedImage.h>

@interface UserInfoViewController ()<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

static NSString *const headerIdentifier = @"headerCell";
static NSString *const identifier = @"cell";

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人信息";
    
    CGFloat barH = NavigationBarH + StatusBarH;
    CGRect frame = CGRectMake(0, barH, Screen_W, Screen_H - barH);
    
    self.dataArray = @[@"头像",@"名字",@"城市",@"身份证",@"二维码",@"Live"];
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:headerIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.layoutMargins = UIEdgeInsetsZero;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:self.tableView];
    
    if ([CustomiseTool isNightModel]) {
        self.tableView.backgroundColor = [UIColor blackColor];
        self.tableView.separatorColor = [UIColor blackColor];
    } else {
        self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.tableView.separatorColor = [UIColor lightGrayColor];
    }
    
#if !TARGET_OS_SIMULATOR
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
    [button setImage:[UIImage imageNamed:@"scanQRCode"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(scanQRCode) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(scanQRCode)];
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.delegate = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.delegate = nil;
}

#pragma mark
- (void)scanQRCode {
    ScanQRCodeController *controller = [[ScanQRCodeController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showAlertControllerOnChangeUsername {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改昵称" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * textField) {
        textField.placeholder = @"请输入昵称";
        textField.text = [UserManager shareManager].username;
        if ([CustomiseTool isNightModel]) {
            textField.keyboardAppearance = UIKeyboardAppearanceDark;
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    __weak typeof(alert) weakAlert = alert;//你妹啊，这都有循环引用
    UIAlertAction *certainAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        UITextField *field = weakAlert.textFields[0];
        [self updateUsername:field.text];
    }];
    [alert addAction:cancelAction];
    [alert addAction:certainAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)presentAddressPickerController {
    AddressPickerController *controller = [[AddressPickerController alloc] init];
    controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
    controller.AddressDismissBlock = ^{
        [self dismissViewControllerAnimated:NO completion:nil];
    };
    controller.SelectBlock = ^(NSDictionary *province,NSDictionary *city) {
        AddressModel *address = [[AddressModel alloc] init];
        address.province = province[@"name"];
        address.city = city[@"name"];
        
        [UserManager shareManager].address = address;
        [UserManager cacheToDisk];
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    };
    [self presentViewController:controller animated:NO completion:nil];
}

#pragma mark
- (void)updateUsername:(NSString *)username {
    [self loading];
    
    NSDictionary *param = @{@"username":username};
    [[HttpConnection defaultConnection] userUpdate:[UserManager shareManager].objectId WithParam:param completion:^(NSDictionary *data, NSError *error) {
        [self hideHUD];
        if (data) {
            [UserManager shareManager].username = username;
            [UserManager cacheToDisk];
            
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [self showError:@"修改失败"];
        }
    }];
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIColor *backgroundColor = ([CustomiseTool isNightModel] ? KCellBackgroundColor : [UIColor whiteColor]);
    
    if (indexPath.row ==0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:headerIdentifier];
        cell.backgroundColor = backgroundColor;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = self.dataArray[indexPath.row];
        
        FLAnimatedImageView *headerImageView = [cell viewWithTag:101];
        if (!headerImageView) {
            headerImageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 80, 10, 50, 50)];
            headerImageView.tag = 101;
            headerImageView.layer.masksToBounds = YES;
            headerImageView.layer.cornerRadius = 25;
            [cell.contentView addSubview:headerImageView];
            
//            NSData *data = [UserManager shareManager].headerImageData;
//            if (data) {
//                if ([NSData sd_imageFormatForImageData:data] == SDImageFormatGIF) {
//                    headerImageView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
//                } else {
//                    headerImageView.image = [UIImage imageWithData:data];
//                }
//            }
            
            [headerImageView sd_setImageWithURL:[NSURL URLWithString:[UserManager shareManager].headerUrl]
                               placeholderImage:[UIImage imageNamed:@"defaultHeader"]];
        }
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            cell.backgroundColor = backgroundColor;
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0 ? 70 : 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        self.navigationController.delegate = self;
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
        IDCardViewController *controller = [[IDCardViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.row == 4) {
        UserQRCodeController *controller = [[UserQRCodeController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.row == 5) {
        InkeViewController *controller = [[InkeViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - UINavigationControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    AnimatedTransitioning *transition = [[AnimatedTransitioning alloc] init];
    if (operation == UINavigationControllerOperationPush) {
        transition.operation = AnimatedTransitioningOperationPush;
    } else {
        transition.operation = AnimatedTransitioningOperationPop;
    }
    transition.transitioningType = AnimatedTransitioningTypeScale;
    transition.originalFrame = CGRectMake(self.view.frame.size.width - 80, 84, 50, 50);
    return transition;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
