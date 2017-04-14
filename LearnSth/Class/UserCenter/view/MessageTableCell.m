//
//  MessageViewCell.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/25.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "MessageTableCell.h"

@interface MessageTableCell()

@property (strong, nonatomic) UIView *contentBackgroundView;
@property (strong, nonatomic) UILabel *contentLabel;

@end

@implementation MessageTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    _contentBackgroundView = [[UIView alloc] init];
    _contentBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_contentBackgroundView];
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.numberOfLines = 0;
    _contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self.contentView addSubview:_contentLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat cellWidth = CGRectGetWidth(self.frame);
    CGFloat cellHeight = CGRectGetHeight(self.frame);
    
    CGRect rect = CGRectMake(0, 0, cellWidth - 20, cellHeight - 20);
    self.contentBackgroundView.frame = CGRectMake(10, 10, cellWidth - 20, cellHeight - 20);
    self.contentBackgroundView.layer.shadowPath = [UIBezierPath bezierPathWithRect:rect].CGPath;
    self.contentBackgroundView.layer.shadowOpacity = 0.1;
    self.contentBackgroundView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.contentBackgroundView.layer.cornerRadius = 3;
    
    self.contentLabel.frame = CGRectMake(20, 20, cellWidth - 40, cellHeight - 40);
}

- (void)setContent:(NSString *)content {
    _content = content;
    
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    [style setLineSpacing:2.0];
    NSDictionary *attribute = @{NSFontAttributeName:font,NSParagraphStyleAttributeName:style};
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:content
                                                                    attributes:attribute];
    self.contentLabel.attributedText = attString;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
