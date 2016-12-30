//
//  UserInfoViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/1.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UserInfoViewController.h"
#import "ProvinceViewController.h"

#import "PopoverViewController.h"

#import "UserModel.h"

@interface UserInfoViewController ()<UITableViewDataSource,UITableViewDelegate,UIPopoverPresentationControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

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
    [button setBackgroundColor:KBaseBlueColor];
    [button setTitle:@"退出登录" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(loginOut) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

#pragma mark
- (void)addClick:(UIBarButtonItem *)item {
    NSArray *array = @[@"Hello",@"Word"];
    
    PopoverViewController *popoverController = [[PopoverViewController alloc] init];
    popoverController.modalPresentationStyle = UIModalPresentationPopover;
    popoverController.dataArray = array;
    
    popoverController.popover.delegate = self;
    popoverController.popover.sourceView = self.navigationController.navigationBar;
    popoverController.popover.sourceRect = CGRectMake(Screen_W - 32, 44, 0, 0);
    
    popoverController.SelectIndex = ^(NSInteger index) {
        NSLog(@"%@",array[index]);
    };
    
    [self presentViewController:popoverController animated:YES completion:nil];
}

- (void)loginOut {
    [Utils remoAllObjects];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 上传头像
- (void)showAlertControllerOnUplodUserHeader {
    UIAlertController *actionSheet;
    actionSheet = [UIAlertController alertControllerWithTitle:@"上传头像"
                                                      message:nil
                                               preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertAction *albumAction;
    albumAction = [UIAlertAction actionWithTitle:@"相册"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * _Nonnull action) {
                                             [self openUserCameraWithType:UIImagePickerControllerSourceTypePhotoLibrary];
                                         }];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertAction *cameraAction;
        cameraAction = [UIAlertAction actionWithTitle:@"相机"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * _Nonnull action) {
                                                  [self openUserCameraWithType:UIImagePickerControllerSourceTypeCamera];
                                              }];
        [actionSheet addAction:cameraAction];
    }
    
    
    [actionSheet addAction:cancelAction];
    [actionSheet addAction:albumAction];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)openUserCameraWithType:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.allowsEditing = YES;
    pickerController.sourceType = sourceType;
    [self presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark 修改昵称
- (void)showAlertControllerOnChangeUsername {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改昵称" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入昵称";
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertAction *certainAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              NSArray *textFields = alert.textFields;
                                                              UITextField *field = textFields[0];
                                                              [[UserModel userManager] setUsername:field.text];
                                                              
                                                              [self.tableView reloadData];
                                                              [Utils setUserModel:[UserModel userManager]];
                                                          }];
    [alert addAction:cancelAction];
    [alert addAction:certainAction];
    
    [self presentViewController:alert animated:YES completion:nil];
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
    if (indexPath.row == 1 && [UserModel userManager].username) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[UserModel userManager].username];
    } else if (indexPath.row == 2 && [UserModel userManager].city) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[UserModel userManager].city];
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
        ProvinceViewController *contoller = [[ProvinceViewController alloc] init];
        [self.navigationController pushViewController:contoller animated:YES];
    }
}

#pragma mark - UIPopoverPresentationControllerDelegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

#pragma mark 
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ViewFrame_X, Screen_W, Screen_H - 64)
                                                  style:UITableViewStylePlain];
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
