//
//  CustomerButton.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/25.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "CustomerButton.h"

const CGFloat spaceScale = 0.1;
const CGFloat imageScale = 0.6;
const CGFloat titleScale = 0.2;

@interface CustomerButton ()
@property (nonatomic, assign) ImagePoisition position;
@end

@implementation CustomerButton

- (void)setImagePoisition:(ImagePoisition)position {
    if (_position != position) {
        _position = position;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    CGRect imageRect;
    CGRect titleRect;
    
    switch (self.position) {
        case ImagePoisitionDefault: {
            break;
        }
        case ImagePoisitionTop: {
            
            imageRect = CGRectMake(0, height * spaceScale, width, height * imageScale);
            titleRect = CGRectMake(0, height * (spaceScale + imageScale), width, height * titleScale);
            break;
        }
        case ImagePoisitionLeft: {
            
            imageRect = CGRectMake(width * spaceScale, 0, width * imageScale, height);
            titleRect = CGRectMake(width * (spaceScale + imageScale), 0, width * titleScale, height);
            break;
        }
        case ImagePoisitionBottom: {
            
            titleRect = CGRectMake(0, height * spaceScale, width, height * titleScale);
            imageRect = CGRectMake(0, height * (titleScale + spaceScale), width, height * imageScale);
            break;
        }
        case ImagePoisitionRight: {
            
            titleRect = CGRectMake(width * spaceScale, 0, width * titleScale, height);
            imageRect = CGRectMake(width * (spaceScale + titleScale), 0, width * imageScale, height);
            break;
        }
        default: {
            break;
        }
    }
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.frame = imageRect;
    
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.frame = titleRect;
}

@end
