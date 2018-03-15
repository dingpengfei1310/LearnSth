//
//  HeaderImageViewCell.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/14.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "HeaderImageViewCell.h"
#import "BaseConfigure.h"
#import "UserManager.h"
#import "CustomiseTool.h"
#import <UIImageView+WebCache.h>

@interface HeaderImageViewCell()

@property (strong, nonatomic) UIImageView *hImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *mobileLabel;

@end

@implementation HeaderImageViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (style == UITableViewCellStyleDefault) {
        style = UITableViewCellStyleValue1;
    }
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    _hImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
    _hImageView.layer.masksToBounds = YES;
    _hImageView.layer.cornerRadius = 25;
    [self.contentView addSubview:_hImageView];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_hImageView.frame) + 10, 10, 200, 25)];
    _nameLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:_nameLabel];
    
    _mobileLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_hImageView.frame) + 10, 35, 200, 25)];
    _mobileLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:_mobileLabel];
}

- (void)setUserModel:(UserManager *)userModel {
    if ([CustomiseTool isLogin]) {
        self.detailTextLabel.text = nil;
        _nameLabel.text = userModel.username;
        _mobileLabel.text = userModel.mobilePhoneNumber;
        
        [_hImageView sd_setImageWithURL:[NSURL URLWithString:userModel.headerUrl]
                       placeholderImage:[UIImage imageNamed:@"defaultHeader"]];
    } else {
        self.detailTextLabel.text = @"点击登录";
        _nameLabel.text = nil;
        _mobileLabel.text = nil;
        _hImageView.image = [UIImage imageNamed:@"defaultHeader"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
