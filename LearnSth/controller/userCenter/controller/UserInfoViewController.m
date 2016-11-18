//
//  UserInfoViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/1.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UserInfoViewController.h"

#import "PopoverViewController.h"

#import "UserModel.h"
#import "Utils.h"

@interface UserInfoViewController ()<UITableViewDataSource,UITableViewDelegate,UIPopoverPresentationControllerDelegate,PopoverViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

static NSString *reuseIdentifier = @"cell";

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人信息";
    
    self.dataArray = @[@"头像",@"昵称"];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 50;
    [self.view addSubview:_tableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClick:)];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, ScreenHeight - 40, ScreenWidth, 40)];
    [button setBackgroundColor:[UIColor redColor]];
    [button setTitle:@"退出登录" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(loginOut) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)addClick:(UIBarButtonItem *)item {
    PopoverViewController *popoverController = [[PopoverViewController alloc] init];
    popoverController.delegate = self;
    popoverController.dataArray = @[@"Hello",@"Word"];
    popoverController.modalPresentationStyle = UIModalPresentationPopover;
    popoverController.preferredContentSize = CGSizeMake(120, self.dataArray.count * 50);
    
    UIPopoverPresentationController *popover = popoverController.popoverPresentationController;
//    popover.barButtonItem = item;
    popover.sourceView = self.navigationController.navigationBar;
    popover.sourceRect = CGRectMake(ScreenWidth - 30, 44, 0, 0);
    popover.delegate = self;
    popover.backgroundColor = [UIColor whiteColor];
    popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    
    [self presentViewController:popoverController animated:YES completion:nil];
}

- (void)loginOut {
    [Utils remoAllObjects];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    if (indexPath.row == 1 && [UserModel user].mobile) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@-%@",self.dataArray[indexPath.row],[UserModel user].mobile];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
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
                                                 [self openUserCameraWithType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
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
    } else if (indexPath.row == 1) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改昵称"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"请输入昵称";
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        UIAlertAction *certainAction = [UIAlertAction actionWithTitle:@"确定"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  
                                                                  NSArray *textFields = alert.textFields;
                                                                  UITextField *field = textFields[0];
                                                                  [Utils setUserNickname:field.text];
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:certainAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)openUserCameraWithType:(UIImagePickerControllerSourceType)type {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.allowsEditing = YES;
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark - UIPopoverPresentationControllerDelegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (void)controller:(PopoverViewController *)controller didSelectAtIndex:(NSInteger)index {
    [controller dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"%@",controller.dataArray[index]);
}

#pragma mark 
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end