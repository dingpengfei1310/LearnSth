//
//  ScanIDCardController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/7.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "ScanIDCardController.h"
#import <AVFoundation/AVFoundation.h>

#if !TARGET_OS_SIMULATOR
#import "IDCardInfo.h"
#import "excards.h"
#endif

@interface ScanIDCardController ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureMetadataOutputObjectsDelegate> {
    CGFloat viewW;
}

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSNumber *outputSetting;

@property (nonatomic, assign) CGRect scanCardFrame;
@property (nonatomic, assign) CGRect scanFaceFrame;

@end

@implementation ScanIDCardController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismisss)];
    
#if !TARGET_OS_SIMULATOR
    viewW = CGRectGetWidth(self.view.frame);
    // 初始化rect
    const char *thePath = [[[NSBundle mainBundle] resourcePath] UTF8String];
    int ret = EXCARDS_Init(thePath);
    if (ret != 0) {
        NSLog(@"初始化失败：ret=%d", ret);
    }
    
    [self showVideoPreviewLayer];//前面已经判断有相机权限，否则会有错误
#endif
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

- (void)showVideoPreviewLayer {
    //创建一个预览图层
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    _previewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:_previewLayer];
    
    CGFloat scanWidth = viewW * 0.75;
    _scanCardFrame = CGRectMake((viewW - scanWidth) / 2, (self.view.frame.size.height - scanWidth * 1.585) / 2, scanWidth, scanWidth * 1.585);
    
    CGFloat faceH = 32.0 / 54 * scanWidth;
    CGFloat faceW = (26.0 / 54) * scanWidth;
    CGRect headerFrame = CGRectMake((viewW - faceH) / 2 + viewW * 0.04, CGRectGetMaxY(_scanCardFrame) - viewW * 0.08 - faceW, faceH, faceW);
    [self addMaskViewWithCardRect:_scanCardFrame faceRect:headerFrame];
    
    _scanFaceFrame = CGRectMake((viewW - faceH) / 2 + viewW * 0.04 + faceH * 0.2, CGRectGetMaxY(_scanCardFrame) - viewW * 0.08 - faceW + faceW * 0.2, faceH * 0.6, faceW * 0.6);
    [self.captureSession startRunning];
    
    CGRect rectOfInterest = [_previewLayer metadataOutputRectOfInterestForRect:_scanFaceFrame];
    _metadataOutput.rectOfInterest = rectOfInterest;
}

- (void)addMaskViewWithCardRect:(CGRect)cardRect faceRect:(CGRect)faceRect {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, viewW, self.view.frame.size.height)];
    [maskPath appendPath:[[UIBezierPath bezierPathWithRoundedRect:cardRect cornerRadius:15] bezierPathByReversingPath]];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    
//    UIBezierPath *facePath = [UIBezierPath bezierPathWithRect:faceRect];
//    CAShapeLayer *faceLayer = [CAShapeLayer layer];
//    faceLayer.path = facePath.CGPath;
//    faceLayer.fillColor = [UIColor clearColor].CGColor;
//    faceLayer.strokeColor = [UIColor whiteColor].CGColor;
//    [maskLayer addSublayer:faceLayer];
    
    UIView *maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    maskView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    maskView.layer.mask = maskLayer;
    [self.view addSubview:maskView];
    
    UIImageView *headIV = [[UIImageView alloc] initWithFrame:faceRect];
    headIV.image = [UIImage imageNamed:@"IDCardHead"];
    headIV.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
    headIV.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:headIV];
    
    CGPoint center = self.view.center;
    center.x = CGRectGetMaxX(cardRect) + 20;
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.text = @"将身份证人像面置于此区域内，头像对准，扫描";
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
    [tipLabel sizeToFit];
    
    tipLabel.center = center;
    [self.view addSubview:tipLabel];
}

#pragma mark
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count) {
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
        AVMetadataObject *transformedMetadataObject = [self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
        CGRect faceRegion = transformedMetadataObject.bounds;
        
        if (metadataObject.type == AVMetadataObjectTypeFace && CGRectContainsRect(_scanFaceFrame, faceRegion)) {
            //只有当人脸区域在小框内，才去捕获此时的这一帧图像
            // 为videoDataOutput设置代理，程序就会自动调用下面的代理方法，捕获每一帧图像
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
#if !TARGET_OS_SIMULATOR
    CVBufferRetain(imageBuffer);
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
        if (ret > 0) {
            NSLog(@"ret=[%d]", ret);
            AudioServicesPlaySystemSound(1108);// 播放一下“拍照”的声音，模拟拍照
            if ([self.captureSession isRunning]) {
                [self.captureSession stopRunning];
            }
            
//            //手机震动
//            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
//            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            
            char ctype;
            char content[256];
            int xlen;
            int i = 0;
            
            IDCardInfo *iDInfo = [[IDCardInfo alloc] init];
            ctype = pResult[i++];
            
            //iDInfo.type = ctype;
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
            
            UIImage *image = [self getImageWithImageBuffer:imageBuffer cardRect:_scanCardFrame];
            //            UIImage *image = [self getImageWithImageBuffer:imageBuffer];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.ScanResult) {
                    self.ScanResult(iDInfo,image);
                }
                if (self.DismissBlock) {
                    self.DismissBlock();
                }
            });
        }
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    }
    CVBufferRelease(imageBuffer);
#endif
}

- (UIImage *)getImageWithImageBuffer:(CVImageBufferRef)imageBuffer {
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer))];
    
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return image;
}

- (UIImage *)getImageWithImageBuffer:(CVImageBufferRef)imageBuffer cardRect:(CGRect)cardRect {
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
    CGImageRef imageRef = [[CIContext contextWithOptions:nil] createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer))];
    
    CGFloat scale = CGRectGetWidth(cardRect) / viewW;
    CGRect imageRect = CGRectMake(CVPixelBufferGetWidth(imageBuffer) * (1 - scale) * 0.5, CVPixelBufferGetHeight(imageBuffer) * (1 - scale) * 0.5, CVPixelBufferGetWidth(imageBuffer) * scale, CVPixelBufferGetHeight(imageBuffer) * scale);
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, imageRect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));

    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    CFRelease(imageRef);
    CFRelease(subImageRef);
    
    return smallImage;
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
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            if ([device isSmoothAutoFocusSupported]) {// 平滑对焦
                device.smoothAutoFocusEnabled = YES;
            }
            if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {// 自动持续对焦
                device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            }
            if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure ]) {// 自动持续曝光
                device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            }
            if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {// 自动持续白平衡
                device.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
            }
            [device unlockForConfiguration];
        }
        
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
