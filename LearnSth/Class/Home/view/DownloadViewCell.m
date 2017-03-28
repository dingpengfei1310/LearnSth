//
//  DownloadViewCell.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/10.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "DownloadViewCell.h"

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
    
    self.sizeLabel.text = @"--/--";
    self.progressView.progress = 0;
    
    self.startButon.titleLabel.font = [UIFont systemFontOfSize:15];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
}

- (void)setFileModel:(DownloadModel *)fileModel {
    _fileModel = fileModel;
    
    self.progressView.hidden = NO;
    self.titleLabel.text = fileModel.fileName;
    if (fileModel.bytesTotal > 0) {
        self.sizeLabel.text = [NSString stringWithFormat:@"%.1fM/%.1fM",fileModel.bytesReceived / 1024.0 / 1024,fileModel.bytesTotal / 1024.0 / 1024];
        self.progressView.progress = fileModel.bytesReceived / 1.0 / fileModel.bytesTotal;
        
    } else {
        self.sizeLabel.text = @"--/--";
        self.progressView.progress = 0;
    }
    
    NSString *stateString = @"";
    NSString *buttonTitle = @"";
    
    if (fileModel.state == DownloadStatePause) {
        stateString = @"暂停";
        buttonTitle = @"开始";
    } else if (fileModel.state == DownloadStateWaiting) {
        stateString = @"等待中";
        buttonTitle = @"暂停";
    } else if (fileModel.state == DownloadStateRunning) {
        stateString = @"下载中";
        buttonTitle = @"暂停";
    } else if (fileModel.state == DownloadStateCompletion) {
        stateString = @"下载完成";
        buttonTitle = @"播放";
        
        self.sizeLabel.text = [NSString stringWithFormat:@"%.1fM",fileModel.bytesTotal / 1024.0 / 1024];
        self.progressView.hidden = YES;
        
    } else if (fileModel.state == DownloadStateFailure) {
        stateString = @"下载失败";
        buttonTitle = @"重新下载";
    }
    
    self.stateLabel.text = stateString;
    [self.startButon setTitle:buttonTitle forState:UIControlStateNormal];
}

- (IBAction)buttonClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(downloadButtonClickIndex:state:)]) {
        [self.delegate downloadButtonClickIndex:self.index state:self.fileModel.state];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
