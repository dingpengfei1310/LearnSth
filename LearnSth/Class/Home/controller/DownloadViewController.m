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

#import "HttpManager.h"

@interface DownloadViewController ()<UITableViewDataSource,UITableViewDelegate,DownloadCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *downloadFile;
@property (nonatomic, strong) DownloadModel *currentModel;
@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"文件下载";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:self action:@selector(addFile)];
    
    _downloadFile = [DownloadModel loadAllDownload];
    [self.view addSubview:self.tableView];
}

- (void)addFile {
    NSString * downloadURLString1 = @"http://baobab.wdjcdn.com/14564977406580.mp4";
    NSString * downloadURLString2 = @"http://baobab.wdjcdn.com/1442142801331138639111.mp4";
    
    DownloadModel *model1 = [[DownloadModel alloc] init];
    model1.fileName = @"下载1.mp4";
    model1.fileUrl = downloadURLString1;
    
    DownloadModel *model2 = [[DownloadModel alloc] init];
    model2.fileName = @"下载2.mp4";
    model2.fileUrl = downloadURLString2;
    
    [DownloadModel add:model2];
    [DownloadModel add:model1];
    
    _downloadFile = [DownloadModel loadAllDownload];
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
    
    DownloadModel *model = self.downloadFile.allValues[indexPath.row];
    cell.fileModel = model;
//    if (model.state == DownloadStateRunning) {
//        [cell.delegate downloadButtonClickIndex:indexPath.row running:NO];
//    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setSeparatorInset:UIEdgeInsetsZero];
}

#pragma mark DownloadCellDelegate
- (void)downloadButtonClickIndex:(NSInteger)index running:(BOOL)running {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    DownloadViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    NSString *str = self.downloadFile.allKeys[index];
    NSURL *url = [NSURL URLWithString:str];
    
    if (running) {
        [[DownloadManager shareManager] pause];
    } else {
        if ([[DownloadManager shareManager] isRunning]) {
            DownloadModel *waitingModel = [[DownloadModel alloc] init];
            waitingModel.state = DownloadStateWaiting;
            cell.fileModel = waitingModel;
            
            return;
        }
        
        __weak typeof(self) wSelf = self;
//        __weak typeof(cell) wCell = cell;
        _currentModel = self.downloadFile[str];
        
        [[DownloadManager shareManager] downloadWithUrl:url state:^(NSURLSessionTaskState state) {
//            self.currentModel.state = DownloadStatePause;
//            cell.fileModel = self.currentModel;
            
        } progress:^(int64_t bytesWritten, int64_t bytesTotal) {
//            __strong typeof(wSelf) strSelf = wSelf;
//            __strong typeof(wCell) strCell = wCell;
//            
//            strSelf.currentModel.bytesReceived = bytesWritten;
//            strSelf.currentModel.bytesTotal = bytesTotal;
//            strSelf.currentModel.state = DownloadStateRunning;
//            strCell.fileModel = strSelf.currentModel;
//            
//            NSLog(@"controller: - %lld - %lld",strSelf.currentModel.bytesReceived,bytesWritten);
            
            wSelf.currentModel.bytesReceived = bytesWritten;
            wSelf.currentModel.bytesTotal = bytesTotal;
            wSelf.currentModel.state = DownloadStateRunning;
            cell.fileModel = wSelf.currentModel;
//
            NSLog(@"controller: - %lld - %lld",wSelf.currentModel.bytesReceived,bytesWritten);
            
        } completion:^(BOOL isSuccess, NSError *error) {
//            self.downloadFile = [DownloadModel loadAllDownload];
//            [self.tableView reloadData];
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

- (void)dealloc {
    NSLog(@"DownloadViewController: -- dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
