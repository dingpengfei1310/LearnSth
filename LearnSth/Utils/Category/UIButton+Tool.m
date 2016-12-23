//
//  UIButton+Tool.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UIButton+Tool.h"

@implementation UIButton (Tool)

- (void)setImagePoisition:(ImagePoisition)position {
    
//    NSLog(@"imageView:%@",[NSValue valueWithCGRect:self.imageView.frame]);
//    NSLog(@"titleLabel:%@",[NSValue valueWithCGRect:self.titleLabel.frame]);
//    
//    CGFloat width = self.bounds.size.width;
//    CGFloat height = self.bounds.size.height;
//    
//    CGFloat imageWith = self.imageView.frame.size.width;
//    CGFloat imageHeight = self.imageView.frame.size.height;
//    
//    CGFloat labelWidth = 0.0;
//    CGFloat labelHeight = 0.0;
//    labelWidth = self.titleLabel.frame.size.width;
//    labelHeight = self.titleLabel.frame.size.height;
//    
//    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
//    UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;
//    
//    switch (position) {
//        case ImagePoisitionTop: {
////            self.imageView.frame = CGRectMake(0, 0, width, height * 0.6);
////            self.imageView.center = CGPointMake(width * 0.5, height * 0.3);
////            
////            self.titleLabel.frame = CGRectMake(0, height * 0.6, width, height * 0.4);
////            self.titleLabel.center = CGPointMake(width * 0.5, height * 0.8);
////            self.titleLabel.textAlignment = NSTextAlignmentCenter;
//            
////            self.titleEdgeInsets = UIEdgeInsetsMake(height * 0.6, 0, 0, 0);
////            self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, height * 0.4, 0);
//            
//            
//            
//            imageEdgeInsets = UIEdgeInsetsMake(-(height - imageHeight) * 0.3, 0, (height - imageHeight) * 0.3, -labelWidth);
//            labelEdgeInsets = UIEdgeInsetsMake((height - labelHeight) * 0.3, -imageWith, -(height - labelHeight) * 0.3, 0);
//            
//            break;
//        }
//        case ImagePoisitionLeft: {
//            break;
//        }
//        case ImagePoisitionBottom: {
//            break;
//        }
//        case ImagePoisitionRight: {
//            break;
//        }
//        default: {
//            break;
//        }
//    }
//    
//    self.titleEdgeInsets = labelEdgeInsets;
//    self.imageEdgeInsets = imageEdgeInsets;
//    
//    NSLog(@"imageView:%@",[NSValue valueWithCGRect:self.imageView.frame]);
//    NSLog(@"titleLabel:%@",[NSValue valueWithCGRect:self.titleLabel.frame]);
    
    [self layoutIfNeeded];
    
}

- (void)layoutSubviews {
//    NSLog(@"layoutSubviews");
}


@end
