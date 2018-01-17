//
//  FileScanViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/20.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "FileScanViewController.h"
#import "DDPreviewItem.h"
#import <QuickLook/QLPreviewController.h>
#import "VideoPlayerController.h"

@interface FileScanViewController ()<UITableViewDataSource,UITableViewDelegate,QLPreviewControllerDataSource>

@property (nonatomic, strong) NSString *previewItemPath;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *previewItems;

@property (nonatomic, assign) NSInteger selectIndex;//显示的文件序号

@property (nonatomic, assign) BOOL editing;
@property (nonatomic, strong) NSMutableArray *selectArray;//删除用

@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIBarButtonItem *deleteItem;

@end

static NSString *const identifier = @"cell";

@implementation FileScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"文件";
    _selectArray = [NSMutableArray array];
    _previewItemPath = KDocumentPath;
    
    [self loadPreviewItems];
    [self.view addSubview:self.tableView];
    [self initToolBar];
}

- (void)initToolBar {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(tableViewEditing:)];
    
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 49, CGRectGetWidth(self.view.frame), 49)];
    _toolBar.hidden = YES;
    [self.view addSubview:_toolBar];
    
    _deleteItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteBarButtonItemClick)];
    _deleteItem.tintColor = [UIColor grayColor];
    _deleteItem.enabled = NO;
    _toolBar.items = @[_deleteItem];
}

#pragma mark
- (void)loadPreviewItems {
    _previewItems = [NSMutableArray array];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:_previewItemPath error:NULL];
    [files enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * stop) {
        if (![obj hasSuffix:@".DS_Store"]) {
            NSString *filePath = [_previewItemPath stringByAppendingPathComponent:obj];
            
            BOOL flag;
            if ([fileManager fileExistsAtPath:filePath isDirectory:&flag] && !flag) {
                [_previewItems addObject:obj];
            }
        }
    }];
}

- (void)tableViewEditing:(UIBarButtonItem *)buttonItem {
    self.editing = !self.editing;
    _toolBar.hidden = !self.editing;
    CGRect rect = self.tableView.frame;
    UIBarButtonSystemItem systemItem;
    
    if (self.editing) {
        rect.size.height -= 49;
        systemItem = UIBarButtonSystemItemCancel;
    } else {
        rect.size.height += 49;
        systemItem = UIBarButtonSystemItemEdit;
        [self.selectArray removeAllObjects];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:self action:@selector(tableViewEditing:)];
    self.tableView.frame = rect;
    [self.tableView reloadData];
}

- (void)deleteBarButtonItemClick {
    [self showAlertWithTitle:nil
                     message:@"确定删除选中的文件吗?"
                      cancel:nil
                 destructive:^{
                     [self deleteSelectArray];
                 }];
}

- (void)deleteSelectArray {
    if (self.selectArray.count == 1) {
        NSIndexPath *indexPath = self.selectArray.firstObject;
        NSString *filePath = [_previewItemPath stringByAppendingPathComponent:_previewItems[indexPath.row]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:filePath error:NULL];
        
        [self.selectArray removeAllObjects];
        [self.previewItems removeObjectAtIndex:indexPath.row];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
    } else {
        for (NSIndexPath *indexPath in self.selectArray) {
            NSString *filePath = [_previewItemPath stringByAppendingPathComponent:_previewItems[indexPath.row]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:filePath error:NULL];
        }
        [self.selectArray removeAllObjects];
        
        _deleteItem.enabled = NO;
        [self loadPreviewItems];
        [self.tableView reloadData];
    }
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.previewItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = KBackgroundColor;
        cell.selectedBackgroundView = backgroundView;
    }
    
    NSString *fileName = self.previewItems[indexPath.row];
    cell.textLabel.text = fileName;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *filePath = [_previewItemPath stringByAppendingPathComponent:fileName];
        
        long long longSize = [CustomiseTool fileSizeAtPath:filePath];
        CGFloat cacheSize = longSize / 1024.0 / 1024.0;
        dispatch_async(dispatch_get_main_queue(),^{
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fM",cacheSize];
        });
    });
    
    if (self.editing) {
        cell.imageView.image = [self.selectArray containsObject:indexPath] ? [UIImage imageNamed:@"switchOn"] : [UIImage imageNamed:@"switchOff"];
    } else {
        cell.imageView.image = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.editing) {
        self.selectIndex = indexPath.row;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        NSString *fileName = self.previewItems[indexPath.row];
        if ([fileName hasSuffix:@"mp4"]) {
            NSString *filePath = [_previewItemPath stringByAppendingPathComponent:fileName];
            VideoPlayerController *cc = [[VideoPlayerController alloc] init];
            cc.title = fileName;
            cc.fileUrl = filePath;
            cc.DismissBlock = ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            };
            [self presentViewController:cc animated:YES completion:nil];
        } else {
            QLPreviewController *previewController = [[QLPreviewController alloc] init];
            previewController.dataSource = self;
            [self presentViewController:previewController animated:YES completion:nil];
        }
        
    } else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@"switchOn"];
        [self.selectArray addObject:indexPath];
        
        _deleteItem.enabled = YES;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editing) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@"switchOff"];
        [self.selectArray removeObject:indexPath];
        
        _deleteItem.enabled = self.selectArray.count > 0;
    }
}

#pragma mark
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editing) {
        return NO;
    }
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self showAlertWithTitle:nil
                         message:@"确定删除这个文件吗?"
                          cancel:^{
                              [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                          }
                     destructive:^{
                         [self.selectArray addObject:indexPath];
                         [self deleteSelectArray];
                     }];
    }
}

//- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * action, NSIndexPath * indexPath) {
//        [self showAlertWithTitle:nil
//                         message:@"确定删除这个文件吗?"
//                          cancel:^{
//                              [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//                          }
//                     destructive:^{
//                         [self.selectArray addObject:indexPath];
//                         [self deleteSelectArray];
//                     }];
//    }];
//
//    return @[action];
//}

#pragma mark - QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    NSString *filePath = [_previewItemPath stringByAppendingPathComponent:self.previewItems[self.selectIndex]];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    DDPreviewItem *previewItem = [[DDPreviewItem alloc] init];
    previewItem.previewItemURL = fileURL;
//    previewItem.previewItemTitle = @"文件";
    
    return previewItem;
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        CGFloat barH = NavigationBarH + StatusBarH;
        CGRect frame = CGRectMake(0, barH, Screen_W, Screen_H - barH);
        
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _tableView.rowHeight = 55;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.allowsMultipleSelection = YES;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
