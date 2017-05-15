//
//  UIImage+Tool.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef NS_ENUM(NSInteger, UIImageResizeMode) {
//    UIImageResizeModeUp,
//    UIImageResizeModeLeft,
//    UIImageResizeModeCenter,
//    UIImageResizeModeBottom,
//    UIImageResizeModeRight
//};

@interface UIImage (Tool)

+ (UIImage *)imageWithColor:(UIColor *)color;

- (UIImage *)resizeImageWithSize:(CGSize)size;
- (UIImage *)cornerImageWithSize:(CGSize)size radius:(CGFloat)radius;

///默认名字为app名字
- (void)saveImageToAlbum;
- (void)saveImageToAlbumWithTitle:(NSString *)title;

@end
