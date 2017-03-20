//
//  UserInfoViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/1.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UserInfoViewController.h"
#import "ProvinceViewController.h"
#import "AddressPickerController.h"
#import "ScanQRCodeController.h"

#import "UserManager.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/PHPhotoLibrary.h>

@interface UserInfoViewController ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *dataArray;

@end

static NSString *reuseIdentifier = @"cell";

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人信息";
    
    self.dataArray = @[@"头像",@"昵称",@"城市"];
    [self.view addSubview:self.tableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClick:)];
    
    CGRect buttonRect = CGRectMake(40, Screen_H - 144, Screen_W - 80, 40);
    UIButton *button = [[UIButton alloc] initWithFrame:buttonRect];
    [button setBackgroundImage:[CustomiseTool imageWithColor:KBaseBlueColor] forState:UIControlStateNormal];
    
    [button setTitle:@"退出登录" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(loginOut) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
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

- (void)loginOut {
    [self showAlertWithTitle:@"提示" message:@"确定要退出登录吗" cancel:nil destructive:^{
        [CustomiseTool remoAllCaches];
        [UserManager deallocManager];
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
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
- (void)showAlertControllerOnUplodUserHeader {
    UIAlertController *actionSheet;
    actionSheet = [UIAlertController alertControllerWithTitle:@"上传头像"
                                                      message:nil
                                               preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self checkAuthorizationStatusWithType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self checkAuthorizationStatusWithType:UIImagePickerControllerSourceTypeCamera];
        }];
        [actionSheet addAction:cameraAction];
    }
    
    [actionSheet addAction:cancelAction];
    [actionSheet addAction:albumAction];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)checkAuthorizationStatusWithType:(UIImagePickerControllerSourceType)sourceType {
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {//相机
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if (status == AVAuthorizationStatusAuthorized) {
            [self openUserCameraWithType:sourceType];
            
        } else if (status == AVAuthorizationStatusDenied) {
            [self showAuthorizationStatusDeniedAlertMessage:@"没有相机访问权限" cancel:nil operation:nil];
            
        } else if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                granted ? [self openUserCameraWithType:sourceType] : 0;
            }];
        }
        
    } else {//相册
        PHAuthorizationStatus currentStatus = [PHPhotoLibrary authorizationStatus];
        
        if (currentStatus == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    status == PHAuthorizationStatusAuthorized ? [self openUserCameraWithType:sourceType] : 0;
                });
            }];
            
        } else if (currentStatus == PHAuthorizationStatusDenied) {
            [self showAuthorizationStatusDeniedAlertMessage:@"没有相册访问权限" cancel:nil operation:nil];
            
        } else if (currentStatus == PHAuthorizationStatusAuthorized) {
            [self openUserCameraWithType:sourceType];
        }
    }
    
}

- (void)openUserCameraWithType:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.allowsEditing = YES;
    pickerController.sourceType = sourceType;
    [self presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    }
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self showAlertControllerOnUplodUserHeader];
        
    } else if (indexPath.row == 1) {
        [self showAlertControllerOnChangeUsername];
        
    } else if (indexPath.row == 2) {
//        ProvinceViewController *contoller = [[ProvinceViewController alloc] initWithStyle:UITableViewStyleGrouped];
//        [self.navigationController pushViewController:contoller animated:YES];
        
        [self presentAddressPickerController];
    }
}

#pragma mark 
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Screen_W, Screen_H) style:UITableViewStylePlain];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 50;
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
