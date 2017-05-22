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

@property (nonatomic, strong) NSString *previewItemPath;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *previewItems;

@property (nonatomic, assign) NSInteger selectIndex;//显示的文件序号

@property (nonatomic, assign) BOOL editing;
@property (nonatomic, strong) NSMutableArray *selectArray;//删除用

@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIBarButtonItem *deleteItem;

@end

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
    
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 49, self.view.frame.size.width, 49)];
    _toolBar.hidden = YES;
    [self.view addSubview:_toolBar];
    
    _deleteItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteSelectArray)];
    _deleteItem.tintColor = [UIColor grayColor];
    _deleteItem.enabled = NO;
    _toolBar.items = @[_deleteItem];
}

#pragma mark
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(tableViewEditing:)];
    self.tableView.frame = rect;
    [self.tableView reloadData];
}

- (void)deleteSelectArray {
    if (self.selectArray.count > 0) {
        [self showAlertWithTitle:@"提示"
                         message:@"确定删除选中的文件吗?"
                          cancel:nil
                     destructive:^{
                         for (NSIndexPath *indexPath in self.selectArray) {
                             NSString *filePath = [_previewItemPath stringByAppendingPathComponent:self.previewItems[indexPath.row]];
                             
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
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:_previewItemPath error:NULL];
    [files enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * stop) {
        NSString *filePath = [_previewItemPath stringByAppendingPathComponent:obj];
        
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
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.selectIndex = indexPath.row;
        
        QLPreviewController *previewController = [[QLPreviewController alloc] init];
        previewController.dataSource = self;
        [self.navigationController pushViewController:previewController animated:YES];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self showAlertWithTitle:@"提示" message:@"确定删除这个文件吗?"
                          cancel:^{
                              [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                          } destructive:^{
                              NSString *filePath = [_previewItemPath stringByAppendingPathComponent:self.previewItems[indexPath.row]];
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
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64) style:UITableViewStylePlain];
        _tableView.backgroundColor = KBackgroundColor;
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
