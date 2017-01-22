//
//  LiveCollectionCell.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/26.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "LiveCollectionCell.h"

#import "LiveModel.h"
#import "UIImageView+WebCache.h"

@interface LiveCollectionCell ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation LiveCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
    
    self.signaturesLabel.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
    [self.contentView addSubview:self.indicatorView];
    NSLog(@"awakeFromNib");
}

- (void)setLiveModel:(LiveModel *)liveModel {
    if (_liveModel != liveModel) {
        _liveModel = liveModel;
        [self.liveImageView sd_setImageWithURL:[NSURL URLWithString:liveModel.smallpic] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [self.indicatorView removeFromSuperview];
            self.indicatorView = nil;
        }];
        self.signaturesLabel.text = liveModel.signatures;
    }
    
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _indicatorView;
}

@end

