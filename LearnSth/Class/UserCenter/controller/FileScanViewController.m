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

#import "VideoProcessWithFilter.h"

@interface FileScanViewController ()<UITableViewDataSource,UITableViewDelegate,QLPreviewControllerDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *previewItems;

@property (nonatomic, assign) NSInteger selectIndex;//显示的文件序号

@property (nonatomic, assign) BOOL editing;
@property (nonatomic, strong) NSMutableArray *selectArray;//删除用

@end

@implementation FileScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"文件";
    
    [self loadPreviewItems];
    [self.view addSubview:self.tableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(tableViewEditing:)];
    _selectArray = [NSMutableArray array];
}

#pragma mark
- (void)tableViewEditing:(UIBarButtonItem *)buttonItem {
    if (self.previewItems.count == 0) {
        return;
    }
    BOOL flag = [buttonItem.title isEqualToString:@"编辑"];
    NSString *title = flag ? @"完成" : @"编辑";
    buttonItem.title = title;
    
    if (flag) {
        UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteSelectArray)];
        self.navigationItem.rightBarButtonItems = @[buttonItem,deleteItem];
    } else {
        self.navigationItem.rightBarButtonItems = nil;
        self.navigationItem.rightBarButtonItem = buttonItem;
        [self.selectArray removeAllObjects];
    }
    
    self.editing = flag;
    [self.tableView reloadData];
}

- (void)deleteSelectArray {
    if (self.selectArray.count > 0) {
        
        [self showAlertWithTitle:@"提示" message:@"确定删除选中的文件吗?"
                          cancel:^{
                          } destructive:^{
                              
                              for (NSIndexPath *indexPath in self.selectArray) {
                                  NSString *filePath = [KDocumentPath stringByAppendingPathComponent:self.previewItems[indexPath.row]];
                                  
                                  NSFileManager *fileManager = [NSFileManager defaultManager];
                                  [fileManager removeItemAtPath:filePath error:NULL];
                              }
                              
                              [self.selectArray removeAllObjects];
                              
                              [self loadPreviewItems];
                              [self.tableView reloadData];
                          }];
    } else {
        [self showError:@"请选择删除的文件"];
    }
}

- (void)loadPreviewItems {
    _previewItems = [NSMutableArray array];
    NSString *docString = KDocumentPath;
    
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *fileName = self.previewItems[indexPath.row];
    cell.textLabel.text = fileName;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *filePath = [KDocumentPath stringByAppendingPathComponent:fileName];
        
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
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.selectIndex = indexPath.row;
        
        QLPreviewController *previewController = [[QLPreviewController alloc] init];
        previewController.dataSource = self;
        [self.navigationController pushViewController:previewController animated:YES];
        
//        NSString *filePath = [KDocumentPath stringByAppendingPathComponent:self.previewItems[indexPath.row]];
//        VideoProcessWithFilter *controller = [[VideoProcessWithFilter alloc] init];
//        controller.filePath = filePath;
//        [self.navigationController pushViewController:controller animated:YES];
        
    } else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@"switchOn"];
        [self.selectArray addObject:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editing) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@"switchOff"];
        [self.selectArray removeObject:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *filePath = [KDocumentPath stringByAppendingPathComponent:self.previewItems[indexPath.row]];
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
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editing) {
        return NO;
    }
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    NSString *filePath = [KDocumentPath stringByAppendingPathComponent:self.previewItems[self.selectIndex]];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    DDPreviewItem *previewItem = [[DDPreviewItem alloc] init];
    previewItem.previewItemURL = fileURL;
//    previewItem.previewItemTitle = @"文件";
    
    return previewItem;
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Screen_W, Screen_H) style:UITableViewStylePlain];
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
