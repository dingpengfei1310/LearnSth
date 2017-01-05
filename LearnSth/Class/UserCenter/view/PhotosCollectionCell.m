//
//  PhotosCollectionCell.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/25.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "PhotosCollectionCell.h"

@implementation PhotosCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.videoLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
}

@end

