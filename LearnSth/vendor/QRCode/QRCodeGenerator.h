//
//  QRCodeGenerator.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/25.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WatermarkMode) {
    WatermarkModeScaleAspectFit,
    WatermarkModeScaleAspectFill
};

@interface QRCodeGenerator : NSObject

@property (nonatomic, strong) NSString *content;
@property (nonatomic, assign) CGFloat codeWidth;

@property (nonatomic, strong) UIColor *foregroundColor;
@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, assign) BOOL isIconColorful;

@property (nonatomic, strong) UIImage *watermark;
@property (nonatomic, assign) WatermarkMode watermarkMode;
@property (nonatomic, assign) BOOL isWatermarkColorful;

@property (nonatomic, assign) BOOL allowTransparent;//是否透明,有水印才会有用

- (UIImage *)QRCodeImage;

@end
