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
//    _contentLabel.layer.masksToBounds = YES;
//    _contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self.contentView addSubview:_contentLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat cellWidth = CGRectGetWidth(self.frame);
    CGFloat cellHeight = CGRectGetHeight(self.frame);
    
    self.contentBackgroundView.frame = CGRectMake(10, 10, cellWidth - 20, cellHeight - 20);
    self.contentLabel.frame = CGRectMake(20, 20, cellWidth - 40, cellHeight - 40);
//    CGRect rect = CGRectMake(0, 0, cellWidth - 20, cellHeight - 20);
//    self.contentBackgroundView.layer.shadowPath = [UIBezierPath bezierPathWithRect:rect].CGPath;
//    self.contentBackgroundView.layer.shadowOpacity = 0.1;
//    self.contentBackgroundView.layer.shadowColor = [UIColor grayColor].CGColor;
//    self.contentBackgroundView.layer.cornerRadius = 3;
}

- (void)setContent:(NSString *)content {
    _content = content;
    
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 1.0;
    style.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *attribute = @{NSFontAttributeName:font,
                                NSParagraphStyleAttributeName:style,
//                                NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),
//                                NSStrikethroughStyleAttributeName:@(NSUnderlinePatternDashDotDot | NSUnderlineStyleSingle),
//                                NSBaselineOffsetAttributeName:@(NSUnderlineStyleSingle)
                                };
    self.contentLabel.attributedText = [[NSAttributedString alloc] initWithString:content attributes:attribute];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
