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

@property (weak, nonatomic) IBOutlet UIView *contentBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation MessageViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat cellWidth = CGRectGetWidth(self.frame);
    CGFloat cellHeight = CGRectGetHeight(self.frame);
    
    CGRect rect = CGRectMake(0, 0, cellWidth - 19, cellHeight - 19);
    self.contentBackgroundView.layer.shadowPath = [UIBezierPath bezierPathWithRect:rect].CGPath;
    self.contentBackgroundView.layer.shadowOpacity = 0.1;
    self.contentBackgroundView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.contentBackgroundView.layer.cornerRadius = 3;
}

- (void)setContent:(NSString *)content {
    _content = content;
    
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    [style setLineSpacing:2.0];
    NSDictionary *attribute = @{NSFontAttributeName:font,NSParagraphStyleAttributeName:style};
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:content
                                                                    attributes:attribute];
    _contentLabel.attributedText = attString;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


@end




