//
//  DownloadViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/10.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "DownloadViewController.h"
#import "DownloadManager.h"
#import "DownloadViewCell.h"
#import "DownloadModel.h"

@interface DownloadViewController ()<UITableViewDataSource,UITableViewDelegate,DownloadCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *downloadFile;
//@property (nonatomic, strong) NSArray *downloadFile;

@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"文件下载";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:self action:@selector(addFile)];
    
    self.downloadFile = [CustomiseTool downloadFile];
    [self.view addSubview:self.tableView];
}

- (void)addFile {
    NSString * downloadURLString1 = @"http://baobab.wdjcdn.com/14564977406580.mp4";
    NSString * downloadURLString2 = @"http://baobab.wdjcdn.com/1442142801331138639111.mp4";
    
    self.downloadFile = @{downloadURLString1:@"文件下载1,暂停,0,0",
                          downloadURLString2:@"文件下载2,暂停,0,0"};
    [CustomiseTool setDownloadFile:self.downloadFile];
    [self.tableView reloadData];
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.downloadFile.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.index = indexPath.row;
    cell.delegate = self;
    
    NSString *str = self.downloadFile.allValues[indexPath.row];
    DownloadModel *model = [self downloadModelWithSting:str];
    cell.fileModel = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setSeparatorInset:UIEdgeInsetsZero];
}

- (DownloadModel *)downloadModelWithSting:(NSString *)str {
    NSArray *array = [str componentsSeparatedByString:@","];
    
    DownloadModel *model = [[DownloadModel alloc] init];
    if (array.count > 0) {
        model.fileName = array[0];
    }
    if (array.count > 1) {
        model.state = array[1];
    }
    if (array.count > 2) {
        model.bytesReceived = [array[2] intValue];
    }
    if (array.count > 3) {
        model.bytesTotal = [array[3] intValue];
    }
    
    return model;
}

#pragma mark DownloadCellDelegate
- (void)downloadButtonClickIndex:(NSInteger)index running:(BOOL)running {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    DownloadViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    NSURL *url = [NSURL URLWithString:self.downloadFile.allKeys[index]];
    
    DownloadModel *currentModel = [[DownloadModel alloc] init];
    currentModel.state = @"下载中";
    cell.fileModel = currentModel;
    
    if (running) {
        [[DownloadManager shareManager] pause];
    } else {
        if ([[DownloadManager shareManager] isRunning]) {
            DownloadModel *currentModel = [[DownloadModel alloc] init];
            currentModel.state = @"等待中";
            cell.fileModel = currentModel;
            
            return;
        }
        
        [[DownloadManager shareManager] downloadWith:url state:^(NSURLSessionTaskState state) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                DownloadModel *currentModel = [[DownloadModel alloc] init];
                currentModel.state = @"暂停";
                currentModel.bytesTotal = -1;
                cell.fileModel = currentModel;
                
                [cell changeButtonState];
            });
        } progress:^(int64_t bytesWritten, int64_t bytesExpected) {
            DownloadModel *currentModel = [[DownloadModel alloc] init];
            currentModel.bytesReceived = bytesWritten;
            currentModel.bytesTotal = bytesExpected;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.fileModel = currentModel;
                
                NSString *str = [NSString stringWithFormat:@"%@,%@,%lld,%lld",url.lastPathComponent,@"暂停",bytesWritten,bytesExpected];
                NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithDictionary:[CustomiseTool downloadFile]];
                [dictM setObject:str forKey:url.absoluteString];
                [CustomiseTool setDownloadFile:dictM];
                
                self.downloadFile = [NSDictionary dictionaryWithDictionary:dictM];
            });
        } completion:^(BOOL isSuccess, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isSuccess) {
                    self.downloadFile = [CustomiseTool downloadFile];
                    [self.tableView reloadData];
                }
            });
        }];
        
    }
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        CGRect frame = CGRectMake(0, 0, Screen_W, Screen_H);
        _tableView = [[UITableView alloc] initWithFrame:frame
                                                  style:UITableViewStylePlain];
        UINib *nib = [UINib nibWithNibName:@"DownloadViewCell" bundle:[NSBundle mainBundle]];
        [_tableView registerNib:nib forCellReuseIdentifier:@"cell"];
        
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 75;
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
