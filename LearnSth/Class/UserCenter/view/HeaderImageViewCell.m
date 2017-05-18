//
//  HeaderImageViewCell.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/14.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "HeaderImageViewCell.h"
#import "UserManager.h"
#import <FLAnimatedImage.h>

@interface HeaderImageViewCell()

@property (strong, nonatomic) FLAnimatedImageView *headerImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *mobileLabel;

@end

@implementation HeaderImageViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.backgroundColor = [UIColor whiteColor];
    
    _headerImageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
    _headerImageView.layer.masksToBounds = YES;
    _headerImageView.layer.cornerRadius = 3;
    [self.contentView addSubview:_headerImageView];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headerImageView.frame) + 10, 10, 200, 25)];
    _nameLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:_nameLabel];
    
    _mobileLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headerImageView.frame) + 10, 35, 200, 25)];
    _mobileLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:_mobileLabel];
}

- (void)setUserModel:(UserManager *)userModel {
    if (userModel.headerImageData) {
        FLAnimatedImage *animationImage = [FLAnimatedImage animatedImageWithGIFData:userModel.headerImageData];
        if (animationImage) {
            _headerImageView.animatedImage = animationImage;
        } else {
            _headerImageView.image = [UIImage imageWithData:userModel.headerImageData];
        }
    } else {
        _headerImageView.image = [UIImage imageNamed:@"defaultHeader"];
    }
    
    _nameLabel.text = userModel.username;
    _mobileLabel.text = userModel.mobile;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
