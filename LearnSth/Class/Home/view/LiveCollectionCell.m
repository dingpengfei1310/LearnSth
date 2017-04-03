//
//  LiveCollectionCell.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/26.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "LiveCollectionCell.h"

#import "LiveModel.h"
#import "RollTextLabel.h"

@interface LiveCollectionCell ()

@property (strong, nonatomic) UIImageView *liveImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) RollTextLabel *signaturesLabel;

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
    [self.contentView addSubview:self.liveImageView];
    
    UIColor *backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.backgroundColor = backgroundColor;
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:self.nameLabel];
    
    _signaturesLabel = [[RollTextLabel alloc] init];
    _signaturesLabel.backgroundColor = backgroundColor;
    [self.contentView addSubview:self.signaturesLabel];
}

- (void)setLiveModel:(LiveModel *)liveModel {
    if (![_liveModel isEqual:liveModel]) {
        
        _liveModel = liveModel;
        NSURL *url = [NSURL URLWithString:liveModel.smallpic];
        [self.liveImageView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            self.liveImageView.frame = self.contentView.bounds;
            
            if (liveModel.myname.length > 0) {
                self.nameLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 21);
                self.nameLabel.text = liveModel.myname;
            }
            
            if (liveModel.signatures.length > 0) {
                self.signaturesLabel.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 21, CGRectGetWidth(self.frame), 21);
                self.signaturesLabel.text = liveModel.signatures;
            }
            
        }];
    }
}

@end
