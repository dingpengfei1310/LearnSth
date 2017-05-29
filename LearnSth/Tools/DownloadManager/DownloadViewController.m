//
//  DownloadViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/10.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "DownloadViewController.h"
#import "VideoPlayerController.h"
#import "AnimatedTransitioning.h"
#import "DownloadManager.h"
#import "DownloadViewCell.h"
#import "DownloadModel.h"

@interface DownloadViewController ()<UITableViewDataSource,UITableViewDelegate,DownloadCellDelegate,UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *downloadFile;
@property (nonatomic, strong) DownloadModel *currentModel;
@property (nonatomic, assign) NSInteger downloadingIndex;

@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"文件下载";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFile)];
    self.downloadingIndex = -1;
    self.downloadFile = [DownloadModel loadAllDownload];
    [self.view addSubview:self.tableView];
}

- (void)addFile {
    NSString *downloadURLString1 = @"http://baobab.wdjcdn.com/1442142801331138639111.mp4";
    NSString *downloadURLString2 = @"http://baobab.wdjcdn.com/14564977406580.mp4";
    
    DownloadModel *model1 = [[DownloadModel alloc] init];
    model1.fileName = @"这可能是一个动画片";
    model1.fileUrl = downloadURLString1;
    model1.state = DownloadStatePause;
    
    DownloadModel *model2 = [[DownloadModel alloc] init];
    model2.fileName = @"好看的电影";
    model2.fileUrl = downloadURLString2;
    model2.state = DownloadStatePause;
    
    [DownloadModel add:model1];
    [DownloadModel add:model2];
    
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
    if (model.state == DownloadStateRunning) {
        [self downloadCell:cell index:indexPath.row];
    } else if (model.state == DownloadStateWaiting && ![DownloadManager shareManager].isDownloading) {
        [self downloadCell:cell index:indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadModel *model = self.downloadFile.allValues[indexPath.row];
    
    VideoPlayerController *controller = [[VideoPlayerController alloc] init];
    controller.downloadModel = model;
    controller.transitioningDelegate = self;
    controller.BackBlock = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setSeparatorInset:UIEdgeInsetsZero];
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    DownloadModel *model = self.downloadFile.allValues[indexPath.row];
//    if (model.state == DownloadStateCompletion) {
//        return YES;
//    }
//    return NO;
//}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DownloadModel *model = self.downloadFile.allValues[indexPath.row];
        [self showAlertWithTitle:@"提示" message:@"确定删除吗?"
                          cancel:^{
                              [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                          } destructive:^{
                              NSURL *url = [NSURL URLWithString:model.fileUrl];
                              [[DownloadManager shareManager] pauseWithUrl:url];
                              
                              NSFileManager *fileManager = [NSFileManager defaultManager];
                              [fileManager removeItemAtPath:model.savePath error:NULL];
                              [fileManager removeItemAtPath:model.resumePath error:NULL];
                              
                              [DownloadModel remove:model];
                              self.downloadFile = [DownloadModel loadAllDownload];
                              
                              [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                          }];
    }
}

#pragma mark DownloadCellDelegate
- (void)downloadButtonClickIndex:(NSInteger)index state:(DownloadState)state {
    if (state == DownloadStateRunning) {
        DownloadModel *model = self.downloadFile.allValues[index];
        NSURL *url = [NSURL URLWithString:model.fileUrl];
        [[DownloadManager shareManager] pauseWithUrl:url];
        
    } else if (state == DownloadStateWaiting) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        DownloadViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        DownloadModel *model = self.downloadFile.allValues[index];
        model.state = DownloadStatePause;
        cell.fileModel = model;
        
        [DownloadModel update:model];
        
    } else if (state == DownloadStatePause || state == DownloadStateFailure) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        DownloadViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        if ([DownloadManager shareManager].isDownloading && self.downloadingIndex != index) {
            
            DownloadModel *waitingModel = self.downloadFile.allValues[index];
            waitingModel.state = DownloadStateWaiting;
            cell.fileModel = waitingModel;
            
            [DownloadModel update:waitingModel];
        } else {
            [self downloadCell:cell index:index];
        }
        
    } else if (state == DownloadStateCompletion) {
        DownloadModel *model = self.downloadFile.allValues[index];
        
        VideoPlayerController *controller = [[VideoPlayerController alloc] init];
        controller.downloadModel = model;
        controller.transitioningDelegate = self;
        controller.BackBlock = ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        [self presentViewController:controller animated:YES completion:nil];
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
        
    } completion:^(BOOL isSuccess, NSError *error) {
        wSelf.downloadFile = [DownloadModel loadAllDownload];
        [wSelf.tableView reloadData];
    }];
}

#pragma mark 
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    AnimatedTransitioning *transition = [[AnimatedTransitioning alloc] init];
    transition.operation = AnimatedTransitioningOperationPresent;
    transition.transitioningType = AnimatedTransitioningTypeMove;
    
    return transition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    AnimatedTransitioning *transition = [[AnimatedTransitioning alloc] init];
    transition.operation = AnimatedTransitioningOperationDismiss;
    transition.transitioningType = AnimatedTransitioningTypeMove;
    
    return transition;
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
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
