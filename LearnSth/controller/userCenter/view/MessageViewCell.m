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

@property (nonatomic, strong) UIImageView *background;
@property (nonatomic, strong) UILabel *contentLabel;
@end

@implementation MessageViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubView];
    }
    return self;
}

- (void)initSubView {
    _background = [[UIImageView alloc] init];
    [self.contentView addSubview:_background];
    
    UIImage *image = [UIImage imageNamed:@"messageCellBackground"];//694*262
//    _background.image = [image stretchableImageWithLeftCapWidth:<#(NSInteger)#> topCapHeight:<#(NSInteger)#>];
    _background.image = image;
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.numberOfLines = 0;
    _contentLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:_contentLabel];
}

- (void)layoutSubviews {
    CGFloat cellWidth = CGRectGetWidth(self.frame);
    CGFloat cellHeight = CGRectGetHeight(self.frame);
    
    [_background mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@5);
        make.left.mas_equalTo(5);
        make.size.mas_equalTo(CGSizeMake(cellWidth - 10, cellHeight - 10));
    }];
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@20);
        make.left.mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(cellWidth - 40, cellHeight - 40));
    }];
}

- (void)setContent:(NSString *)content {
    _content = content;
    _contentLabel.text = content;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}


@end
