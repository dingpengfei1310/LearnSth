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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(QRCodeCreate)];
}

- (void)QRCodeCreate {
    [self.view endEditing:YES];
    
    NSString *qrString = [self.qrTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (qrString.length == 0) {
        [self showError:@"输入正确的文字"];
        return;
    }
    
//    self.qrImageView.image = [self QRCodeNormalImage:qrString imageWidth:CGRectGetWidth(self.qrImageView.frame)];
//    self.qrImageView.image = [self QRCodeColorImage:qrString imageWidth:CGRectGetWidth(self.qrImageView.frame) frontColor:[UIColor purpleColor] backgroundColor:nil];
    self.qrImageView.image = [self QRCodeWatermarkImage:qrString imageWidth:CGRectGetWidth(self.qrImageView.frame) watermark:nil];
}

#pragma mark
- (CIImage *)QRCodeOriginalImage:(NSString *)qrString {
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    return qrFilter.outputImage;
}

///普通二维码
- (UIImage *)QRCodeNormalImage:(NSString *)qrString imageWidth:(CGFloat)imageWidth {
    imageWidth = MAX(27, imageWidth);
    CIImage *ciImage = [self QRCodeOriginalImage:qrString];
    
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

///水印二维码
- (UIImage *)QRCodeWatermarkImage:(NSString *)qrString imageWidth:(CGFloat)imageWidth watermark:(UIImage *)watermark {
    UIImage *normalImage = [self QRCodeNormalImage:qrString imageWidth:imageWidth];
//    UIImage *normalImage = [self QRCodeColorImage:qrString imageWidth:imageWidth frontColor:[UIColor purpleColor] backgroundColor:nil];
    if (!watermark) {
        NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
        NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
        watermark = [UIImage imageNamed:icon];
//        return normalImage; 
    }
    
    //加水印
    UIGraphicsBeginImageContextWithOptions(normalImage.size, NO, 0);
    [normalImage drawInRect:CGRectMake(0,0 , imageWidth, imageWidth)];
    CGFloat waterImagesize = imageWidth * 0.2;
    [watermark drawInRect:CGRectMake((imageWidth - waterImagesize)/2.0, (imageWidth - waterImagesize)/2.0, waterImagesize, waterImagesize)];
    UIImage *watermarkImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return watermarkImage;
}

///彩色二维码
- (UIImage *)QRCodeColorImage:(NSString *)qrString imageWidth:(CGFloat)imageWidth frontColor:(UIColor *)frontColor backgroundColor:(UIColor *)bColor {
    UIImage *image = [self QRCodeNormalImage:qrString imageWidth:imageWidth];
    if (!frontColor && !bColor) {
        return image;
    }
    
    CGFloat fRed = 0;
    CGFloat fGreen = 0;
    CGFloat fBlue = 0;
    if (frontColor) {
        const CGFloat *fComponents = CGColorGetComponents(frontColor.CGColor);
        fRed = fComponents[0] * 255;
        fGreen = fComponents[1] * 255;
        fBlue = fComponents[2] * 255;
    }
    
    CGFloat bRed = 255;
    CGFloat bGreen = 255;
    CGFloat bBlue = 255;
    if (bColor) {
        const CGFloat *bComponents = CGColorGetComponents(bColor.CGColor);
        bRed = bComponents[0] * 255;
        bGreen = bComponents[1] * 255;
        bBlue = bComponents[2] * 255;
    }
    
    const int colorWidth = image.size.width;
    const int colorHeight = image.size.height;
    
    size_t bytesPerRow = colorWidth * 4;
    uint32_t *rgbImageBuf = (uint32_t*)malloc(bytesPerRow * colorHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, colorWidth, colorHeight, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, colorWidth, colorHeight), image.CGImage);
    // 遍历像素
    int pixelNum = colorWidth * colorHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900) {
            // 改成下面的代码，会将图片转成想要的颜色。这里理解为：二维码颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = fRed; //0~255
            ptr[2] = fGreen;
            ptr[1] = fBlue;
        } else {
            //这里理解为：背景色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;//透明
//            ptr[3] = bRed; //0~255
//            ptr[2] = bGreen;
//            ptr[1] = bBlue;
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * colorHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(colorWidth, colorHeight, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* colorImage = [UIImage imageWithCGImage:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return colorImage;
}

void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

#pragma mark
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
