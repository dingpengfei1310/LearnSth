//
//  ScanIDCardController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/7.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "ScanIDCardController.h"
#import "IDCardInfo.h"
#import "excards.h"

#import <AVFoundation/AVFoundation.h>

@interface ScanIDCardController ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSNumber *outputSetting;

@property (nonatomic, assign) CGRect scanFaceFrame;

@end

@implementation ScanIDCardController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"deleteButtonImage"] style:UIBarButtonItemStylePlain target:self action:@selector(dismisss)];
    
    // 初始化rect
    const char *thePath = [[[NSBundle mainBundle] resourcePath] UTF8String];
    int ret = EXCARDS_Init(thePath);
    if (ret != 0) {
        NSLog(@"初始化失败：ret=%d", ret);
    }
    
    [self checkAuthorizationStatusOnVideo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self navigationBarColorClear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self navigationBarColorRestore];
    [self.captureSession stopRunning];
}

#pragma mark
- (void)dismisss {
    if (self.DismissBlock) {
        self.DismissBlock();
    }
}

- (void)checkAuthorizationStatusOnVideo {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusAuthorized) {
        [self showVideoPreviewLayer];
    } else if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
        [self showAuthorizationStatusDeniedAlertMessage:@"没有相机访问权限" cancel:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        } operation:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
    } else if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                granted ? [self showVideoPreviewLayer] : [self dismissViewControllerAnimated:YES completion:nil];
            });
        }];
    }
}

- (void)showVideoPreviewLayer {
    //创建一个预览图层
    AVCaptureVideoPreviewLayer *preLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    preLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:preLayer];
    
    CGFloat scanWidth = Screen_W * 0.8;
    CGRect scanRect = CGRectMake((Screen_W - scanWidth) / 2, (Screen_H - scanWidth * 1.585) / 2, scanWidth, scanWidth * 1.585);
    
    CGFloat faceH = 32.0 / 54 * scanWidth;
    CGFloat faceW = 26.0 / 54 * scanWidth;
    _scanFaceFrame = CGRectMake((Screen_W - faceH) / 2, CGRectGetMaxY(scanRect) - Screen_W / 15 - faceW, faceH, faceW);
    
    [self addMaskViewWithRect:scanRect];
    [self.captureSession startRunning];
    
    CGRect rectOfInterest = [preLayer metadataOutputRectOfInterestForRect:_scanFaceFrame];
    _metadataOutput.rectOfInterest = rectOfInterest;
}

- (void)addMaskViewWithRect:(CGRect)scanRect {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, Screen_W, Screen_H)];
    [maskPath appendPath:[[UIBezierPath bezierPathWithRoundedRect:scanRect cornerRadius:15] bezierPathByReversingPath]];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    
    UIBezierPath *facePath = [UIBezierPath bezierPathWithRect:_scanFaceFrame];
    CAShapeLayer *faceLayer = [CAShapeLayer layer];
    faceLayer.path = facePath.CGPath;
    faceLayer.fillColor = [UIColor clearColor].CGColor;
    faceLayer.strokeColor = [UIColor blackColor].CGColor;
    [maskLayer addSublayer:faceLayer];
    
    UIView *maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    maskView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    maskView.layer.mask = maskLayer;
    [self.view addSubview:maskView];
    
    UIImageView *headIV = [[UIImageView alloc] initWithFrame:_scanFaceFrame];
    headIV.image = [UIImage imageNamed:@"IDCardHead"];
    headIV.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
    headIV.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:headIV];
}

#pragma mark
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count) {
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
        
        if (metadataObject.type == AVMetadataObjectTypeFace) {
            if (!self.videoOutput.sampleBufferDelegate) {
                [self.videoOutput setSampleBufferDelegate:self queue:self.queue];
            }
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if ([self.outputSetting isEqualToNumber:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]] || [self.outputSetting isEqualToNumber:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]]) {
        
        if ([self.videoOutput isEqual:captureOutput]) {
            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            [self IDCardRecognit:imageBuffer];
            
            if (self.videoOutput.sampleBufferDelegate) {
                [self.videoOutput setSampleBufferDelegate:nil queue:self.queue];
            }
        }
        
    }
}

- (void)IDCardRecognit:(CVImageBufferRef)imageBuffer {
    CVBufferRetain(imageBuffer);
    
    // Lock the image buffer
    if (CVPixelBufferLockBaseAddress(imageBuffer, 0) == kCVReturnSuccess) {
        size_t width= CVPixelBufferGetWidth(imageBuffer);// 1920
        size_t height = CVPixelBufferGetHeight(imageBuffer);// 1080
        
        CVPlanarPixelBufferInfo_YCbCrBiPlanar *planar = CVPixelBufferGetBaseAddress(imageBuffer);
        size_t offset = NSSwapBigIntToHost(planar->componentInfoY.offset);
        size_t rowBytes = NSSwapBigIntToHost(planar->componentInfoY.rowBytes);
        unsigned char* baseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
        unsigned char* pixelAddress = baseAddress + offset;
        
        static unsigned char *buffer = NULL;
        if (buffer == NULL) {
            buffer = (unsigned char *)malloc(sizeof(unsigned char) * width * height);
        }
        
        memcpy(buffer, pixelAddress, sizeof(unsigned char) * width * height);
        
        unsigned char pResult[1024];
        int ret = EXCARDS_RecoIDCardData(buffer, (int)width, (int)height, (int)rowBytes, (int)8, (char*)pResult, sizeof(pResult));
        if (ret <= 0) {
            NSLog(@"ret=[%d]", ret);
        } else {
            NSLog(@"ret=[%d]", ret);
            
            // 播放一下“拍照”的声音，模拟拍照
            AudioServicesPlaySystemSound(1108);
            
            if ([self.captureSession isRunning]) {
                [self.captureSession stopRunning];
            }
            
            char ctype;
            char content[256];
            int xlen;
            int i = 0;
            
            IDCardInfo *iDInfo = [[IDCardInfo alloc] init];
            
            ctype = pResult[i++];
            
            //            iDInfo.type = ctype;
            while(i < ret){
                ctype = pResult[i++];
                for(xlen = 0; i < ret; ++i){
                    if(pResult[i] == ' ') { ++i; break; }
                    content[xlen++] = pResult[i];
                }
                
                content[xlen] = 0;
                
                if(xlen) {
                    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                    if(ctype == 0x21) {
                        iDInfo.num = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if(ctype == 0x22) {
                        iDInfo.name = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if(ctype == 0x23) {
                        iDInfo.gender = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if(ctype == 0x24) {
                        iDInfo.nation = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if(ctype == 0x25) {
                        iDInfo.address = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if(ctype == 0x26) {
                        iDInfo.issue = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if(ctype == 0x27) {
                        iDInfo.valid = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    }
                }
            }
            
            UIImage *image = [self getImageWith:imageBuffer];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.ScanResult) {
                    self.ScanResult(iDInfo,image);
                }
                if (self.DismissBlock) {
                    self.DismissBlock();
                }
            });
            
            
//            if (iDInfo.num.length) {// 读取到身份证信息，实例化出IDInfo对象后，截取身份证的有效区域，获取到图像
//                CGRect effectRect = [RectManager getEffectImageRect:CGSizeMake(width, height)];
//                CGRect rect = [RectManager getGuideFrame:effectRect];
//                
//                UIImage *image = [UIImage getImageStream:imageBuffer];
//                UIImage *subImage = [UIImage getSubImage:rect inImage:image];
//                
//                // 推出IDInfoVC（展示身份证信息的控制器）
//                IDInfoViewController *IDInfoVC = [[IDInfoViewController alloc] init];
//                
//                IDInfoVC.IDInfo = iDInfo;// 身份证信息
//                IDInfoVC.IDImage = subImage;// 身份证图像
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.navigationController pushViewController:IDInfoVC animated:YES];
//                });
//            }
        }
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    }
    
    CVBufferRelease(imageBuffer);
}

- (UIImage *)getImageWith:(CVImageBufferRef)imageBuffer {
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer))];
    
    UIImage *image = [[UIImage alloc] initWithCGImage:videoImage];
    CGImageRelease(videoImage);
    
    return image;
}

#pragma mark
- (dispatch_queue_t)queue {
    if (!_queue) {
        _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return _queue;
}

- (NSNumber *)outputSetting {
    if (!_outputSetting) {
        _outputSetting = @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange);
    }
    return _outputSetting;
}

- (AVCaptureVideoDataOutput *)videoOutput {
    if (!_videoOutput) {
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        _videoOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:self.outputSetting};
    }
    return _videoOutput;
}

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
//        NSError *error = nil;
//        if ([device lockForConfiguration:&error]) {
//            if ([device isSmoothAutoFocusSupported]) {// 平滑对焦
//                device.smoothAutoFocusEnabled = YES;
//            }
//            if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {// 自动持续对焦
//                device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
//            }
//            if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure ]) {// 自动持续曝光
//                device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
//            }
//            if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {// 自动持续白平衡
//                device.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
//            }
//        }
//        [device unlockForConfiguration];
        
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
        
        _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_metadataOutput setMetadataObjectsDelegate:self queue:self.queue];
        
        //将输入输出设备添加到会话中
        if ([_captureSession canAddInput:videoDeviceInput]) {
            [_captureSession addInput:videoDeviceInput];
        }
        if ([_captureSession canAddOutput:self.videoOutput]) {
            [_captureSession addOutput:self.videoOutput];
        }
        if ([_captureSession canAddOutput:_metadataOutput]) {
            [_captureSession addOutput:_metadataOutput];
            _metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
        }
    }
    return _captureSession;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
