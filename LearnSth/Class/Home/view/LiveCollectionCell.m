//
//  LiveCollectionCell.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/26.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "LiveCollectionCell.h"
#import "LiveModel.h"
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
    CGFloat cellWidth = CGRectGetWidth(self.contentView.bounds);
    
    _liveImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cellWidth, cellWidth)];
    [self.contentView addSubview:_liveImageView];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, cellWidth - 21, cellWidth * 0.7 - 2, 21)];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.font = [UIFont boldSystemFontOfSize:10];
    _nameLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_nameLabel];
    
    _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth * 0.7, cellWidth - 21, cellWidth * 0.3 - 2, 21)];
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.font = [UIFont systemFontOfSize:10];
    _countLabel.textAlignment = NSTextAlignmentRight;
    _countLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_countLabel];
    
    CGRect rect = CGRectMake(-2, -14, cellWidth, 35);
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = rect;
    gradientLayer.shadowPath = [UIBezierPath bezierPathWithRect:rect].CGPath;
    gradientLayer.colors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor,(id)[UIColor colorWithWhite:0.0 alpha:0.8].CGColor];
    gradientLayer.locations = @[@(0.0),@(1.0)];
    gradientLayer.shadowOffset = CGSizeMake(0, 0);
    [self.nameLabel.layer addSublayer:gradientLayer];
}

- (void)setLiveModel:(LiveModel *)liveModel {
    _liveModel = liveModel;
    
    self.nameLabel.text = liveModel.myname;
    self.countLabel.text = liveModel.watchers;
    
    NSURL *url = [NSURL URLWithString:liveModel.bigpic];
    [self.liveImageView sd_setImageWithURL:url];
}

@end
