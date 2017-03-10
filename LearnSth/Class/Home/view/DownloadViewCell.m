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
}

- (void)setFileModel:(DownloadModel *)fileModel {
    self.titleLabel.text = fileModel.fileName;
    self.sizeLabel.text = [NSString stringWithFormat:@"%.2f/%.2f",fileModel.bytesReceived / 1024.0 / 1024,fileModel.bytesTotal / 1024.0 / 1024];
    self.progressView.progress = fileModel.bytesReceived / 1.0 / fileModel.bytesTotal;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)buttonClick:(UIButton *)sender {
    if (self.CellButtonClick) {
        self.CellButtonClick(sender.selected);
    }
    
    sender.selected = !sender.selected;
}

@end
