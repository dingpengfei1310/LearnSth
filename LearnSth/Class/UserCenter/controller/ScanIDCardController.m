//
//  ScanIDCardController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/7.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "ScanIDCardController.h"
#import <AVFoundation/AVFoundation.h>

#import "IDCardInfo.h"
#import "excards.h"

@interface ScanIDCardController ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSNumber *outputSetting;

@end

@implementation ScanIDCardController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫描身份证";
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClick:)];
}

- (void)addClick:(UINavigationItem *)sender {
    [self.videoOutput setSampleBufferDelegate:self queue:self.queue];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkAuthorizationStatusOnVideo];
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
    
    [self.captureSession startRunning];
    
//    CGRect scanRect = CGRectMake((Screen_W - scanWidth) / 2, (Screen_H - scanWidth) / 2, scanWidth, scanWidth);
//    CGRect rectOfInterest = [preLayer metadataOutputRectOfInterestForRect:scanRect];
//    _metadataOutput.rectOfInterest = rectOfInterest;
    
//    [self addMaskViewWithRect:scanRect];
}

#pragma mark
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if ([self.outputSetting isEqualToNumber:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]] || [self.outputSetting isEqualToNumber:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]]) {
        
        if ([self.videoOutput isEqual:captureOutput]) {
            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            [self IDCardRecognit:imageBuffer];
            
//            [self.videoOutput setSampleBufferDelegate:nil queue:self.queue];
        }
        
    } else {
        NSLog(@"didOutputSampleBuffer ************");
    }
}

- (void)IDCardRecognit:(CVImageBufferRef)imageBuffer {
    NSLog(@"IDCardRecognit ++++++");
    
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
            [self.videoOutput setSampleBufferDelegate:nil queue:self.queue];
            
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
            
            NSLog(@"%@",iDInfo);
            if (iDInfo.num.length) {// 读取到身份证信息，实例化出IDInfo对象后，截取身份证的有效区域，获取到图像
//                CGRect effectRect = [RectManager getEffectImageRect:CGSizeMake(width, height)];
//                CGRect rect = [RectManager getGuideFrame:effectRect];
                
//                UIImage *image = [UIImage getImageStream:imageBuffer];
//                UIImage *subImage = [UIImage getSubImage:rect inImage:image];
                
//                // 推出IDInfoVC（展示身份证信息的控制器）
//                IDInfoViewController *IDInfoVC = [[IDInfoViewController alloc] init];
//                
//                IDInfoVC.IDInfo = iDInfo;// 身份证信息
//                IDInfoVC.IDImage = subImage;// 身份证图像
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.navigationController pushViewController:IDInfoVC animated:YES];
//                });
            }
        }
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    }
    
    CVBufferRelease(imageBuffer);
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
        [_videoOutput setSampleBufferDelegate:self queue:self.queue];
    }
    return _videoOutput;
}

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
        
        //将输入输出设备添加到会话中
        if ([_captureSession canAddInput:videoDeviceInput]) {
            [_captureSession addInput:videoDeviceInput];
        }
        if ([_captureSession canAddOutput:self.videoOutput]) {
            [_captureSession addOutput:self.videoOutput];
        }
    }
    return _captureSession;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
