//
//  DownloadViewCell.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/10.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "DownloadViewCell.h"
#import "DownloadModel.h"

@interface DownloadViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *startButon;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation DownloadViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.startButon setBackgroundColor:KBackgroundColor];
    [self.startButon setTitle:@"开始" forState:UIControlStateNormal];
    [self.startButon setTitle:@"暂停" forState:UIControlStateSelected];
    
    self.sizeLabel.text = @"--/--";
    self.progressView.progress = 0;
}

- (void)setFileModel:(DownloadModel *)fileModel {
    _fileModel = fileModel;
    
    self.titleLabel.text = fileModel.fileName;
    
    NSString *stateString = @"";
    if (fileModel.state == DownloadStatePause) {
        _startButon.selected = NO;
        stateString = @"暂停";
    } else if (fileModel.state == DownloadStateWaiting) {
        _startButon.selected = YES;
        stateString = @"等待中";
    } else if (fileModel.state == DownloadStateRunning) {
        _startButon.selected = YES;
        stateString = @"下载中";
    } else if (fileModel.state == DownloadStateFailure) {
        _startButon.selected = NO;
        stateString = @"下载失败";
    }
    self.stateLabel.text = stateString;
    
    if (fileModel.bytesTotal > 0) {
        self.sizeLabel.text = [NSString stringWithFormat:@"%.1fM/%.1fM",fileModel.bytesReceived / 1024.0 / 1024,fileModel.bytesTotal / 1024.0 / 1024];
        self.progressView.progress = fileModel.bytesReceived / 1.0 / fileModel.bytesTotal;
        
    } else {
        self.sizeLabel.text = @"--/--";
        self.progressView.progress = 0;
    }
}

- (IBAction)buttonClick:(UIButton *)sender {
    _startButon.selected = !_startButon.selected;
    [self.delegate downloadButtonClickIndex:self.index running:_startButon.selected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
