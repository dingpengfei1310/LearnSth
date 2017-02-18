//
//  FileScanViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/20.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "FileScanViewController.h"

#import <QuickLook/QLPreviewController.h>
#import "DDPreviewItem.h"

@interface FileScanViewController ()<UITableViewDataSource,UITableViewDelegate,QLPreviewControllerDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *previewItems;

@property (nonatomic, assign) NSInteger selectIndex;//显示的文件序号

@end

@implementation FileScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"文件";
    [self.view addSubview:self.tableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(tableViewEditing:)];
}

- (void)tableViewEditing:(UIBarButtonItem *)buttonItem {
    BOOL flag = [buttonItem.title isEqualToString:@"编辑"];
    [self.tableView setEditing:flag animated:YES];
    
    NSString *title = flag ? @"完成" : @"编辑";
    self.navigationItem.rightBarButtonItem.title = title;
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.previewItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = self.previewItems[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectIndex = indexPath.row;
    
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    previewController.dataSource = self;
    [self.navigationController pushViewController:previewController animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *filePath = [kDocumentPath stringByAppendingPathComponent:self.previewItems[indexPath.row]];
    [self showAlertWithTitle:@"提示" message:@"确定删除这个文件吗?"
                      cancel:^{
                          [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                      } destructive:^{
                          NSFileManager *fileManager = [NSFileManager defaultManager];
                          [fileManager removeItemAtPath:filePath error:NULL];
                          
                          [self.previewItems removeObjectAtIndex:indexPath.row];
                          [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                      }];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    [NSUserDefaults standardUserDefaults];
    NSString *filePath = [kDocumentPath stringByAppendingPathComponent:self.previewItems[self.selectIndex]];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    DDPreviewItem *previewItem = [[DDPreviewItem alloc] init];
    previewItem.previewItemURL = fileURL;
    previewItem.previewItemTitle = @"文件";
    
    return previewItem;
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ViewFrame_X, Screen_W, Screen_H) style:UITableViewStylePlain];
        _tableView.rowHeight = 55;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (NSMutableArray *)previewItems {
    if (!_previewItems) {
        _previewItems = [NSMutableArray array];
        NSString *docString = kDocumentPath;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *files = [fileManager contentsOfDirectoryAtPath:docString error:NULL];
        [files enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * stop) {
            NSString *filePath = [docString stringByAppendingPathComponent:obj];
            
            BOOL flag;
            if ([fileManager fileExistsAtPath:filePath isDirectory:&flag] && !flag) {
                [_previewItems addObject:obj];
            }
        }];
    }
    
    return _previewItems;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
