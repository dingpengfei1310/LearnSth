//
//  UserQRCodeController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/11.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "UserQRCodeController.h"

@interface UserQRCodeController ()

@property (weak, nonatomic) IBOutlet UITextField *qrTextField;
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;

@end

@implementation UserQRCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"二维码生成";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(QRCodeProduct)];
}

- (void)QRCodeProduct {
    [self.view endEditing:YES];
    
    NSString *qrString = [self.qrTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (qrString.length == 0) {
        [self showError:@"输入正确的字符"];
        return;
    }
    
    self.qrImageView.image = [self normalQRCode:qrString size:CGRectGetWidth(self.qrImageView.frame)];
//    self.qrImageView.image = [self watermarkQRCode:qrString size:CGRectGetWidth(self.qrImageView.frame) watermark:[UIImage imageNamed:@"reflesh1"]];
//    self.qrImageView.image = [self colorQRCode:qrString
//                                          size:CGRectGetWidth(self.qrImageView.frame)
//                                     frontColor:KBaseBlueColor];
}

#pragma mark
- (CIImage *)QRCodeOriginal:(NSString *)qrString {
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    return qrFilter.outputImage;
}

- (UIImage *)normalQRCode:(NSString *)qrString size:(CGFloat)imageWidth {
    imageWidth = MAX(27, imageWidth);
    
    CIImage *ciImage = [self QRCodeOriginal:qrString];
    
    CGRect extent = CGRectIntegral(ciImage.extent);
    CGFloat scale = MIN(imageWidth / CGRectGetWidth(extent), imageWidth / CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef contextRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    CGImageRef imageRef = [[CIContext contextWithOptions:nil] createCGImage:ciImage fromRect:extent];
    
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    CGContextScaleCTM(contextRef, scale, scale);
    CGContextDrawImage(contextRef, extent, imageRef);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(contextRef);
    CGContextRelease(contextRef);
    CGImageRelease(imageRef);
    
    return [UIImage imageWithCGImage:scaledImage];
}

- (UIImage *)watermarkQRCode:(NSString *)qrString size:(CGFloat)imageWidth watermark:(UIImage *)watermark{
//    UIImage *normalImage = [self normalQRCode:qrString size:imageWidth];
    UIImage *normalImage = [self colorQRCode:qrString size:imageWidth frontColor:KBaseBlueColor];
    if (!watermark) {
        return normalImage;
    }
    
    //加水印
    UIGraphicsBeginImageContextWithOptions(normalImage.size, NO, 0);
    [normalImage drawInRect:CGRectMake(0,0 , imageWidth, imageWidth)];
    CGFloat waterImagesize = imageWidth * 0.3;
    [watermark drawInRect:CGRectMake((imageWidth - waterImagesize)/2.0, (imageWidth - waterImagesize)/2.0, waterImagesize, waterImagesize)];
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newPic;
}

void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

- (UIImage *)colorQRCode:(NSString *)qrString size:(CGFloat)width frontColor:(UIColor *)frontColor {
    UIImage *image = [self normalQRCode:qrString size:width];
    if (!frontColor) {
        return image;
    }
    
    const CGFloat *components = CGColorGetComponents(frontColor.CGColor);
    CGFloat red = components[0] * 255;
    CGFloat green = components[1] * 255;
    CGFloat blue = components[2] * 255;
    
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    
    size_t bytesPerRow = imageWidth * 4;
    uint32_t *rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900) {
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }
        else {
            // 将白色变成透明
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return resultUIImage;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
