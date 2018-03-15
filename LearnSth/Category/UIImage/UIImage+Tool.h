//
//  UIImage+Tool.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Tool)

+ (UIImage *)imageWithColor:(UIColor *)color;

- (UIImage *)resizeImageWithSize:(CGSize)size;
- (UIImage *)cornerImageWithSize:(CGSize)size radius:(CGFloat)radius;

///创建相册并保存图片，默认名字为app名字
- (BOOL)saveImageToAlbum;
- (BOOL)saveImageToAlbumWithTitle:(NSString *)title;

///图片某一点的颜色
- (UIColor *)colorInPoint:(CGPoint)point;

@end
