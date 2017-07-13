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
    _liveImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_liveImageView];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.backgroundColor = [UIColor whiteColor];
    _nameLabel.font = [UIFont systemFontOfSize:12];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_nameLabel];
}

- (void)setLiveModel:(LiveModel *)liveModel {
    if (![_liveModel isEqual:liveModel]) {
        _liveModel = liveModel;
        
        NSURL *url = [NSURL URLWithString:liveModel.bigpic];
        [self.liveImageView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            CGFloat width = CGRectGetWidth(self.contentView.bounds);
            self.liveImageView.frame = CGRectMake(0, 0, width, width);
            
            if (liveModel.myname.length > 0) {
                self.nameLabel.frame = CGRectMake(0, width, width, 21);
                self.nameLabel.text = liveModel.myname;
            }
        }];
    }
}

@end
