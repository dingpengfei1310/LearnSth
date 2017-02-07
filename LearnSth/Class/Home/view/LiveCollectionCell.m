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
@end

@implementation LiveCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.signaturesLabel.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
}

- (void)setLiveModel:(LiveModel *)liveModel {
    if (_liveModel != liveModel) {
        
        _liveModel = liveModel;
        NSURL *url = [NSURL URLWithString:liveModel.smallpic];
        [self.liveImageView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            self.signaturesLabel.text = liveModel.signatures;
        }];
    }
    
}

@end
