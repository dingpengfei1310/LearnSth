//
//  JPuzzleViewCell.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/6/23.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "JPuzzleViewCell.h"

@interface JPuzzleViewCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation JPuzzleViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        _imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    _imageView.image = image;
    _imageView.frame = self.bounds;
}

@end
