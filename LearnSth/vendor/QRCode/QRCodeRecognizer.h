//
//  QRCodeRecognizer.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/26.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QRCodeRecognizer : NSObject

@property (nonatomic, strong) UIImage *codeImage;

- (NSString *)getQRString;

@end
