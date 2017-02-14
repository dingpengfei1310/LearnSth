//
//  VideoCustomiseController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/2/14.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "VideoCustomiseController.h"
#import <AVFoundation/AVFoundation.h>
#import "GPUImage.h"

@interface VideoCustomiseController ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *videoDeviceInput;//
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;

@property (nonatomic, strong) NSString *moviePath;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, assign) BOOL isRecoding;

@property (nonatomic, strong) GPUImageView *movieView;
@property (nonatomic, strong) GPUImageMovie *movieFile;

@end

static dispatch_semaphore_t semaphore;

@implementation VideoCustomiseController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self checkAuthorizationStatusOnVideo];
}

- (void)showVideoPreviewLayer {
    semaphore = dispatch_semaphore_create(1);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@-Video.mov",dateString];
    self.moviePath = [kDocumentPath stringByAppendingPathComponent:fileName];
    
//    //创建一个预览图层
//    AVCaptureVideoPreviewLayer *preLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
//    preLayer.frame = self.view.bounds;
//    [self.view.layer addSublayer:preLayer];
    
    self.movieView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.movieView];
    
    self.movieFile = [[GPUImageMovie alloc] init];
    self.movieFile.playAtActualSpeed = YES;
    [self.movieFile addTarget:self.movieView];
    
    [self.captureSession startRunning];
    
    [self.view addSubview:self.timeLabel];
    [self setButton];
}

- (void)checkAuthorizationStatusOnVideo {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusAuthorized) {
        [self checkAuthorizationStatusOnAudio];
    } else if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
        [self showAuthorizationStatusDeniedAlertMessage:@"没有相机访问权限" Cancel:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        } operation:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
    } else if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            granted ? [self checkAuthorizationStatusOnAudio] : [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

- (void)checkAuthorizationStatusOnAudio {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    if (status == AVAuthorizationStatusAuthorized) {
        [self showVideoPreviewLayer];
    } else if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
        [self showAuthorizationStatusDeniedAlertMessage:@"没有麦克风访问权限" Cancel:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        } operation:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
    } else if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            granted ? [self showVideoPreviewLayer] : [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

#pragma mark
- (void)setButton {
    CGFloat bottomHeight = 70;
    
    UIButton *dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 42)];
    dismissButton.center = CGPointMake(Screen_W * 0.5 - Screen_W * 0.2, Screen_H - bottomHeight);
    UIImage *originalImage = [UIImage imageNamed:@"backButtonImage"];
    UIImage *image = [UIImage imageWithCGImage:originalImage.CGImage
                                         scale:2.0
                                   orientation:UIImageOrientationLeft];
    [dismissButton setImage:image forState:UIControlStateNormal];
    [dismissButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dismissButton];
    
    UIButton *captureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 49, 49)];
    captureButton.center = CGPointMake(Screen_W * 0.5, Screen_H - bottomHeight);
    [captureButton setImage:[UIImage imageNamed:@"redSpot"] forState:UIControlStateNormal];
    [captureButton addTarget:self action:@selector(captureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:captureButton];
    
    UIButton *changeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 42)];
    changeButton.center = CGPointMake(Screen_W * 0.5 + Screen_W * 0.2, Screen_H - bottomHeight);
    [changeButton setTitle:@"切换" forState:UIControlStateNormal];
    [changeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [changeButton addTarget:self action:@selector(changeDevice:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeButton];
}

- (void)dismiss:(UIButton *)sender {
    [self.captureSession stopRunning];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)changeDevice:(UIButton *)sender {
    AVCaptureDevicePosition position;
    
    AVCaptureDevice *currentDevice = self.videoDeviceInput.device;
    if (currentDevice.position == AVCaptureDevicePositionBack) {
        position = AVCaptureDevicePositionFront;
    } else {
        position = AVCaptureDevicePositionBack;
    }
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        (camera.position == position) ? device = camera : 0;
    }
    
    AVCaptureDeviceInput *changeInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
    
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self.captureSession beginConfiguration];
    //移除原有输入对象
    [self.captureSession removeInput:self.videoDeviceInput];
    //添加新的输入对象
    if ([self.captureSession canAddInput:changeInput]) {
        [self.captureSession addInput:changeInput];
        self.videoDeviceInput = changeInput;
    }
    //提交会话配置
    [self.captureSession commitConfiguration];
}

- (void)captureButtonClick:(UIButton *)sender {
    
//    if (self.movieFileOutput.recording) {
//        [self.movieFileOutput stopRecording];
//        
//        [self.displayLink invalidate];
//        self.displayLink = nil;
//        self.timeLabel.text = nil;
//        
//        return;
//    }
//    
//    //设置录制视频保存的路径
//    NSURL *url = [NSURL fileURLWithPath:self.moviePath];
//    [self.movieFileOutput startRecordingToOutputFileURL:url recordingDelegate:self];
    
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)refreshTime:(CADisplayLink *)link {
//    CMTime time = self.movieFileOutput.recordedDuration;
//    NSInteger totalSecond = time.value / time.timescale;
//    
//    NSInteger hour = 0;
//    NSInteger minute = 0;
//    NSInteger second = 0;
//    
//    if (totalSecond >= 3600) {
//        hour = totalSecond / 3600;
//        minute = (totalSecond % 3600) / 600;
//        second = totalSecond % 60;
//    } else if (totalSecond >= 60) {
//        minute = totalSecond / 60;
//        second = totalSecond % 60;
//    } else {
//        second = totalSecond % 60;
//    }
//    
//    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hour,minute,second];
    
    
    NSLog(@"%f -- %f",link.timestamp,link.duration)
    
}

//- (uint64_t)currentTimestamp{
//    
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//    
//    uint64_t currentts = 0;
//    
//    if(_isFirstFrame == true) {
//        
//        _timestamp = NOW;
//        
//        _isFirstFrame = false;
//        
//        currentts = 0;
//        
//    }
//    
//    else {
//        
//        currentts = NOW - _timestamp;
//        
//    }
//    
//    dispatch_semaphore_signal(semaphore);
//    
//    return currentts;
//    
//}

- (UIImage *)dddIMage:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(buffer, 0);
    
    //从 CVImageBufferRef 取得影像的细部信息
    uint8_t *base;
    size_t width, height, bytesPerRow;
    base = CVPixelBufferGetBaseAddress(buffer);
    width = CVPixelBufferGetWidth(buffer);
    height = CVPixelBufferGetHeight(buffer);
    bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    
    
    
    void *src_buff = CVPixelBufferGetBaseAddress(buffer);
    NSData *data = [NSData dataWithBytes:src_buff length:bytesPerRow * height];
    UIImage *image = [UIImage imageWithData:data];
    
    
//    //利用取得影像细部信息格式化 CGContextRef
//    CGColorSpaceRef colorSpace;
//    CGContextRef cgContext;
//    colorSpace = CGColorSpaceCreateDeviceRGB();
////    cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
//    cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little);
//    
//    CGColorSpaceRelease(colorSpace);
//    
//    //透过 CGImageRef 将 CGContextRef 转换成 UIImage
//    CGImageRef cgImage = CGBitmapContextCreateImage(cgContext);
//    UIImage *image = [UIImage imageWithCGImage:cgImage];
//    CGImageRelease(cgImage);
//    CGContextRelease(cgContext);
    
//    CVPixelBufferUnlockBaseAddress(buffer, 0);
    
    return image;
}

#pragma mark
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
//    [self.videoEncoder encodeWithSampleBuffer:sampleBuffer timeStamp:self.currentTimestamp completionBlock:^(NSData *data, NSInteger length) {
//        
//        fwrite(data.bytes, 1, length, _h264File);
//        
//    }];
    
    [self.movieFile processMovieFrame:sampleBuffer];
}

#pragma mark
- (AVCaptureDeviceInput *)videoDeviceInput {
    if (!_videoDeviceInput) {
        //默认摄像头输入设备，后置摄像头
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        _videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    }
    return _videoDeviceInput;
}

- (AVCaptureVideoDataOutput *)videoDataOutput {
    if (!_videoDataOutput) {
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        
        //kCVPixelFormatType_32BGRA
        NSDictionary *setting = @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
         [_videoDataOutput setVideoSettings:setting];
    }
    return _videoDataOutput;
}

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        
//        //创建麦克风设备，输入设备
//        AVCaptureDevice *deviceAudio = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
//        AVCaptureDeviceInput *inputAudio = [AVCaptureDeviceInput deviceInputWithDevice:deviceAudio error:nil];
        
        _captureSession = [[AVCaptureSession alloc] init];
        //        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
        
        //将输入输出设备添加到会话中
        if ([_captureSession canAddInput:self.videoDeviceInput]) {
            [_captureSession addInput:self.videoDeviceInput];
        }
//        if ([_captureSession canAddInput:inputAudio]) {
//            [_captureSession addInput:inputAudio];
//        }
        if ([_captureSession canAddOutput:self.videoDataOutput]) {
            [_captureSession addOutput:self.videoDataOutput];
        }
    }
    return _captureSession;
}

- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(refreshTime:)];
        _displayLink.frameInterval = 60;
    }
    return _displayLink;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, Screen_W, 21)];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    return _timeLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
