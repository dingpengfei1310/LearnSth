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

@end

@implementation LiveCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.backgroundColor = [UIColor whiteColor];
    
    CGFloat width = CGRectGetWidth(self.contentView.bounds);
    
    _liveImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    [self.contentView addSubview:_liveImageView];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, width, width, 21)];
    _nameLabel.backgroundColor = [UIColor whiteColor];
    _nameLabel.font = [UIFont systemFontOfSize:12];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_nameLabel];
}

- (void)setLiveModel:(LiveModel *)liveModel {
    _liveModel = liveModel;
    
    if (liveModel.myname.length > 0) {
        self.nameLabel.text = liveModel.myname;
    } else {
        self.nameLabel.text = @"";
    }
    
    NSURL *url = [NSURL URLWithString:liveModel.bigpic];
    [self.liveImageView sd_setImageWithURL:url];
}

@end
