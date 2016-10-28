//
//  UserViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UserViewController.h"

#import "WiFiUploadManager.h"

#import "PhotoLiarbraryViewController.h"
#import "MessageViewController.h"

#import "PopoverViewController.h"

@interface UserViewController ()<UITableViewDataSource,UITableViewDelegate,UIPopoverPresentationControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

static NSString *identifier = @"cell";

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"User";
    self.dataArray = @[@"上传文件",@"查看相册",@"消息"];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 50;
    [self.view addSubview:_tableView];
    
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
//    [cell addGestureRecognizer:longPress];
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self wifiUpload];
    } else if (indexPath.row == 1) {
        PhotoLiarbraryViewController *controller = [[PhotoLiarbraryViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.row == 2) {
        MessageViewController *controller = [[MessageViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}

#pragma mark - UIPopoverPresentationControllerDelegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gesture locationInView:self.tableView];
        NSIndexPath *indexpath = [self.tableView indexPathForRowAtPoint:point];
        
        UIView *view = gesture.view;
        
        PopoverViewController *popoverController = [[PopoverViewController alloc] init];
        popoverController.content = self.dataArray[indexpath.row];
        popoverController.modalPresentationStyle = UIModalPresentationPopover;
        popoverController.preferredContentSize = CGSizeMake(100, 50);
        
        UIPopoverPresentationController *popover = popoverController.popoverPresentationController;
        popover.sourceView = view;
        popover.sourceRect = view.bounds;
        popover.delegate = self;
        popover.backgroundColor = [UIColor greenColor];
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
        
        [self presentViewController:popoverController animated:YES completion:nil];
    }
    
}

#pragma mark
- (void)wifiUpload {
    WiFiUploadManager *manager = [WiFiUploadManager shareManager];
    BOOL success = [manager startHTTPServerAtPort:10000];
    
    if (success) {
        NSLog(@"URL = %@:%@",manager.ip,@(manager.port));
        NSLog(@"PATH = %@",manager.savePath);
        [[WiFiUploadManager shareManager] showWiFiPageViewController:self.navigationController];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
