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
@property (nonatomic, strong) DownloadModel *currentModel;
@property (nonatomic, assign) NSInteger downloadingIndex;

@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"文件下载";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:self action:@selector(addFile)];
    
    self.downloadingIndex = -1;
    self.downloadFile = [DownloadModel loadAllDownload];
    [self.view addSubview:self.tableView];
}

- (void)addFile {
    NSString * downloadURLString1 = @"http://baobab.wdjcdn.com/1442142801331138639111.mp4";
    NSString * downloadURLString2 = @"http://baobab.wdjcdn.com/14564977406580.mp4";
    
    DownloadModel *model1 = [[DownloadModel alloc] init];
    model1.fileName = @"下载1.mp4";
    model1.fileUrl = downloadURLString1;
    model1.state = DownloadStatePause;
    
    DownloadModel *model2 = [[DownloadModel alloc] init];
    model2.fileName = @"下载2.mp4";
    model2.fileUrl = downloadURLString2;
    model2.state = DownloadStatePause;
    
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.index = indexPath.row;
    cell.delegate = self;
    
    DownloadModel *model = self.downloadFile.allValues[indexPath.row];
    cell.fileModel = model;
    if (model.state == DownloadStateRunning || model.state == DownloadStateWaiting) {
        [self downloadCell:cell index:indexPath.row];
    } else if (model.state == DownloadStateWaiting && ![DownloadManager shareManager].isDownloading) {
        [self downloadCell:cell index:indexPath.row];
    }
    
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
        if ([DownloadManager shareManager].isDownloading && self.downloadingIndex != index) {
            NSString *str = self.downloadFile.allKeys[index];
            DownloadModel *waitingModel = self.downloadFile[str];
            waitingModel.state = DownloadStateWaiting;
            cell.fileModel = waitingModel;
            
            [DownloadModel update:waitingModel];
        } else {
            [self downloadCell:cell index:index];
        }
    } else {
        if ([DownloadManager shareManager].isDownloading && self.downloadingIndex == index) {
            [[DownloadManager shareManager] pauseWithUrl:url];
            
        } else {
            NSString *str = self.downloadFile.allKeys[index];
            DownloadModel *pauseModel = self.downloadFile[str];
            pauseModel.state = DownloadStatePause;
            cell.fileModel = pauseModel;
            
            [DownloadModel update:pauseModel];
        }
    }
}

- (void)downloadCell:(DownloadViewCell *)cell index:(NSInteger)index {
    self.downloadingIndex = index;
    NSString *key = self.downloadFile.allKeys[index];
    NSURL *url = [NSURL URLWithString:key];
    
    _currentModel = self.downloadFile[key];
    __weak typeof(self) wSelf = self;
    __weak typeof(cell) wCell = cell;
    
    [[DownloadManager shareManager] downloadWithUrl:url state:^(DownloadState state) {
        switch (state) {
            case DownloadStatePause:
            {
                wSelf.currentModel.state = DownloadStatePause;
                wCell.fileModel = wSelf.currentModel;
                [DownloadModel update:wSelf.currentModel];
                
                wSelf.downloadFile = [DownloadModel loadAllDownload];
                [wSelf.tableView reloadData];
                break;
            }
            case DownloadStateFailure:
            {
                wSelf.currentModel.state = DownloadStateFailure;
                wCell.fileModel = wSelf.currentModel;
                [DownloadModel update:wSelf.currentModel];
                
                wSelf.downloadFile = [DownloadModel loadAllDownload];
                [wSelf.tableView reloadData];
                break;
            }
            default:
                break;
        }
        
    } progress:^(int64_t bytesWritten, int64_t bytesTotal) {
        
        wSelf.currentModel.bytesReceived = bytesWritten;
        wSelf.currentModel.bytesTotal = bytesTotal;
        wSelf.currentModel.state = DownloadStateRunning;
        wCell.fileModel = wSelf.currentModel;
        NSLog(@"%ld",bytesWritten);
    } completion:^(BOOL isSuccess, NSError *error) {
        wSelf.downloadFile = [DownloadModel loadAllDownload];
        [wSelf.tableView reloadData];
    }];
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
