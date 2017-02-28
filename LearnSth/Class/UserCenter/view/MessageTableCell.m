//
//  MessageViewCell.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/25.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "MessageTableCell.h"

@interface MessageTableCell()

@property (weak, nonatomic) IBOutlet UIView *contentBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation MessageTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    
    self.contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
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
    self.contentLabel.attributedText = attString;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
