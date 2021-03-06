//
//  SettingViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/14.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "SettingViewController.h"
#import "RootViewController.h"
#import "MessageViewController.h"
#import "DownloadViewController.h"
#import "FileScanViewController.h"
#import "AboutViewController.h"

#import "FileManager.h"
#import "WiFiUploadManager.h"
#import "UserManager.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) UIColor *cellBackgroundColor;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    
    self.dataArray = @[@"消息",
                       @"我的下载",
                       @"本机文件",
                       @"清除缓存",
                       @"语言",
                       @"关于"];
    [self.view addSubview:self.tableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(wifiUpload)];
    
}

#pragma mark
- (void)wifiUpload {
    if ([[WiFiUploadManager shareManager] startHTTPServer]) {
        FFPrint(@"%@",[WiFiUploadManager shareManager].savePath);
        FFPrint(@"%@:%d",[WiFiUploadManager shareManager].ip,[WiFiUploadManager shareManager].port);
        [[WiFiUploadManager shareManager] showWiFiPageViewController:self];
    } else {
        [self showError:@"创建失败"];
    }
}

- (void)showAlertControllerToFile {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"输入密码" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * textField) {
        textField.secureTextEntry = YES;
        textField.placeholder = @"请输入密码";
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
        if ([field.text isEqualToString:@"0000"]) {
            [self enterFileController:YES];
        } else {
            [self showError:@"密码错误"];
        }
    }];
    [alert addAction:cancelAction];
    [alert addAction:certainAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

///Yes直接进入，不需要密码
- (void)enterFileController:(BOOL)password {
    if (password) {
        FileScanViewController *controller = [[FileScanViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [self showAlertControllerToFile];
    }
}

///计算缓存大小
- (CGFloat)calculateDiskCacheSize {
    long long longSize = [FileManager folderSizeAtPath:KCachePath];
    CGFloat cacheSize = longSize / 1000.0 / 1000.0;
    return cacheSize;
}

- (void)showAlertOnClearDiskCache {
    [self showAlertWithTitle:nil message:@"确定要清除缓存吗" cancel:nil destructive:^{
        [self clearDiskCache];
    }];
}

- (void)clearDiskCache {
    [self loadingWithText:@"清除中"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [FileManager clearCacheAtPath:KCachePath];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideHUDAnimation];
            [self.tableView reloadData];
        });
    });
}

- (void)showAlertOnChangeLanguage {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:DLocalizedString(@"切换语言") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *sys = [UIAlertAction actionWithTitle:DLocalizedString(@"系统")
                                                  style:[self styleWithType:LanguageTypeAuto]
                                                handler:^(UIAlertAction * action) {
                                                    [self changeLanguage:LanguageTypeAuto];
                                                }];
    UIAlertAction *zh = [UIAlertAction actionWithTitle:DLocalizedString(@"简体中文")
                                                 style:[self styleWithType:LanguageTypeZH]
                                               handler:^(UIAlertAction * action) {
                                                   [self changeLanguage:LanguageTypeZH];
                                               }];
    UIAlertAction *en = [UIAlertAction actionWithTitle:DLocalizedString(@"英语")
                                                 style:[self styleWithType:LanguageTypeEn]
                                               handler:^(UIAlertAction * action) {
                                                   [self changeLanguage:LanguageTypeEn];
                                               }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:DLocalizedString(@"取消")
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [actionSheet addAction:sys];
    [actionSheet addAction:zh];
    [actionSheet addAction:en];
    [actionSheet addAction:cancel];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (UIAlertActionStyle)styleWithType:(LanguageType)type {
    return [CustomiseTool languageType] == type ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault;
}

- (void)changeLanguage:(LanguageType)type {
    if ([CustomiseTool languageType] != type) {
        [self loading];
        [CustomiseTool changeLanguage:type];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideHUD];
            
            RootViewController *controller = (RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            [controller loadViewControllersWithSelectIndex:2];
        });
    }
}

- (void)logOut {
    [self showAlertWithTitle:nil message:@"确定要退出登录吗" cancel:nil destructive:^{
        [CustomiseTool remoAllCaches];
        [UserManager deallocManager];
        
        if (self.LogoutBlock) {
            self.LogoutBlock();
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = self.cellBackgroundColor;
    }
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.detailTextLabel.text = nil;
    
    if (indexPath.row == 3) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            CGFloat cacheSize = [self calculateDiskCacheSize];
            dispatch_async(dispatch_get_main_queue(),^{
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fM",cacheSize];
            });
        });
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        MessageViewController *controller = [[MessageViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if (indexPath.row == 1) {
        DownloadViewController *controller = [[DownloadViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if (indexPath.row == 2) {
//        [self enterFileController:YES];
        
        NSError *serror;
        LAContext *context = [[LAContext alloc] init];
        
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&serror]) {
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                    localizedReason:@"请验证你的指纹"
                              reply:^(BOOL success, NSError * _Nullable error) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      if (success) {
                                          [self enterFileController:YES];
                                      } else if (error.code == LAErrorUserFallback) {
                                          [self enterFileController:NO];
                                      }
                                  });
                              }];
        } else {
            if (serror.code == LAErrorTouchIDNotEnrolled || serror.code == LAErrorPasscodeNotSet) {
                [self enterFileController:YES];
            } else if (serror.code == LAErrorTouchIDLockout) {
                [self showError:@"指纹已被锁定，请稍后再试"];
            }
        }
        
    } else if (indexPath.row == 3) {
        [self showAlertOnClearDiskCache];
        
    } else if (indexPath.row == 4) {
        [self showAlertOnChangeLanguage];
        
    } else if (indexPath.row == 5) {
        AboutViewController *controller = [[AboutViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        CGFloat barH = NavigationBarH + StatusBarH;
        CGRect frame = CGRectMake(0, barH, Screen_W, Screen_H - barH);
        
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 50;
        _tableView.sectionHeaderHeight = 0.0;
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.layoutMargins = UIEdgeInsetsZero;
        
        if ([CustomiseTool isNightModel]) {
            _tableView.backgroundColor = [UIColor blackColor];
            _tableView.separatorColor = [UIColor blackColor];
            _cellBackgroundColor = KCellBackgroundColor;
        } else {
            _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
            _tableView.separatorColor = [UIColor lightGrayColor];
            _cellBackgroundColor = [UIColor whiteColor];
        }
        
        if ([CustomiseTool isLogin]) {
            UIButton *logoutButon = [UIButton buttonWithType:UIButtonTypeSystem];
            logoutButon.backgroundColor = _cellBackgroundColor;
            logoutButon.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
            
            [logoutButon setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [logoutButon setTitle:@"退出登录" forState:UIControlStateNormal];
            [logoutButon addTarget:self action:@selector(logOut) forControlEvents:UIControlEventTouchUpInside];
            _tableView.tableFooterView = logoutButon;
        }
        
        
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
