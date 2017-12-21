//
//  LiveCollectionCell.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/26.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "LiveCollectionCell.h"
#import "LiveModel.h"
#import "BaseConfigure.h"
#import <UIImageView+WebCache.h>

@interface LiveCollectionCell ()

@property (strong, nonatomic) UIImageView *liveImageView;
@property (strong, nonatomic) UILabel *nameLabel;

@property (strong, nonatomic) UILabel *countLabel;

@end

@implementation LiveCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self initialize];
    }
    return self;
}

- (void)initialize {
    CGFloat width = CGRectGetWidth(self.contentView.bounds);
    
    _liveImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    [self.contentView addSubview:_liveImageView];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, width, width * 0.7, 21)];
    _nameLabel.backgroundColor = [UIColor whiteColor];
    _nameLabel.font = [UIFont systemFontOfSize:12];
    _nameLabel.textColor = KBaseTextColor;
    [self.contentView addSubview:_nameLabel];
    
    _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(width * 0.7, width, width * 0.3, 21)];
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.font = [UIFont boldSystemFontOfSize:10];
    _countLabel.textAlignment = NSTextAlignmentRight;
    _countLabel.textColor = KBaseAppColor;
    [self.contentView addSubview:_countLabel];
}

- (void)setLiveModel:(LiveModel *)liveModel {
    _liveModel = liveModel;
    
    self.nameLabel.text = liveModel.myname;
    
    NSInteger count = liveModel.allnum.integerValue;
    if (count < 10000) {
        self.countLabel.text = [NSString stringWithFormat:@"%ld",count];
    } else if (count < 1000000) {
        self.countLabel.text = [NSString stringWithFormat:@"%.2f万",count / 10000.0];
    } else {
        self.countLabel.text = [NSString stringWithFormat:@"%.0f万",count / 10000.0];
    }
    
    NSURL *url = [NSURL URLWithString:liveModel.bigpic];
    [self.liveImageView sd_setImageWithURL:url];
}

@end
