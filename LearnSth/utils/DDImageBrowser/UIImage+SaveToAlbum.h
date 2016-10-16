//
//  UIImage+SaveToAlbum.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/16.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SaveToAlbum)

///默认名字为app名字
- (void)saveImageIntoAlbum;

- (void)saveImageIntoAlbumWithTitle:(NSString *)title;

@end
