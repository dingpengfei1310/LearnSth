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
}

- (void)setFileModel:(DownloadModel *)fileModel {
    if (fileModel.fileName) {
        self.titleLabel.text = fileModel.fileName;
    }
    if (fileModel.state) {
        self.stateLabel.text = fileModel.state;
    }
    if (fileModel.bytesTotal > 0) {
        self.sizeLabel.text = [NSString stringWithFormat:@"%.1fM/%.1fM",fileModel.bytesReceived / 1024.0 / 1024,fileModel.bytesTotal / 1024.0 / 1024];
        self.progressView.progress = fileModel.bytesReceived / 1.0 / fileModel.bytesTotal;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)buttonClick:(UIButton *)sender {
    [self.delegate downloadButtonClickIndex:self.index running:_startButon.selected];
    _startButon.selected = !_startButon.selected;
}

- (void)changeButtonState {
    _startButon.selected = NO;
}

@end
