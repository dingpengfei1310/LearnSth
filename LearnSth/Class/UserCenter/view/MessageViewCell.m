//
//  MessageViewCell.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/25.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "MessageViewCell.h"
#import "Masonry.h"

@interface MessageViewCell()

@property (nonatomic, strong) UIView *contentLabelView;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation MessageViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubView];
    }
    return self;
}

- (void)initSubView {
    
    _contentLabelView = [[UIView alloc] init];
    _contentLabelView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_contentLabelView];
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.numberOfLines = 0;
    _contentLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:_contentLabel];
}

- (void)layoutSubviews {
    CGFloat cellWidth = CGRectGetWidth(self.frame);
    CGFloat cellHeight = CGRectGetHeight(self.frame);
    
    [_contentLabelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@10);
        make.left.mas_equalTo(10);
        make.size.mas_equalTo(CGSizeMake(cellWidth - 20, cellHeight - 20));
    }];
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@20);
        make.left.mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(cellWidth - 40, cellHeight - 40));
    }];
    
    CGRect rect = CGRectMake(0, 0, cellWidth - 10, cellHeight - 10);
    self.contentLabelView.layer.shadowPath = [UIBezierPath bezierPathWithRect:rect].CGPath;
    self.contentLabelView.layer.shadowOpacity = 0.1;
    self.contentLabelView.layer.cornerRadius = 3;
    self.contentLabelView.layer.masksToBounds = YES;
}

- (void)setContent:(NSString *)content {
    _content = content;
    _contentLabel.text = content;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}


@end
