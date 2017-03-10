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

@interface DownloadViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *downloadFile;
//@property (nonatomic, strong) NSArray *downloadFile;

@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:self action:@selector(addFile)];
    
    self.downloadFile = [CustomiseTool downloadFile];
    [self.view addSubview:self.tableView];
}

- (void)addFile {
//    NSString * downloadURLString = @"http://baobab.wdjcdn.com/14564977406580.mp4";
    NSString * downloadURLString = @"http://baobab.wdjcdn.com/1442142801331138639111.mp4";
    
    if (![self.downloadFile.allKeys containsObject:downloadURLString]) {
        self.downloadFile = @{downloadURLString:@"0"};
        [CustomiseTool setDownloadFile:self.downloadFile];
        [self.tableView reloadData];
    }
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.downloadFile.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSURL *url = [NSURL URLWithString:self.downloadFile.allKeys[indexPath.row]];
    
    
    typeof(DownloadViewCell) *wCell = cell;
    cell.CellButtonClick  = ^(BOOL running){
        if (running) {
            [[DownloadManager shareManager] pause];
        } else {
            [[DownloadManager shareManager] downloadWith:url progress:^(int64_t bytesWritten, int64_t bytesExpected) {
                DownloadModel *currentModel = [[DownloadModel alloc] init];
                currentModel.bytesReceived = bytesWritten;
                currentModel.bytesTotal = bytesExpected;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    wCell.fileModel = currentModel;
                });
            } completion:^(BOOL isSuccess, NSError *error) {
                self.downloadFile = [CustomiseTool downloadFile];
                [self.tableView reloadData];
            }];
        }
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setSeparatorInset:UIEdgeInsetsZero];
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
        _tableView.rowHeight = 60;
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
