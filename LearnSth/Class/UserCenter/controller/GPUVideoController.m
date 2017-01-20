//
//  GPUVideoController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/1/20.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "GPUVideoController.h"
#import <AVFoundation/AVFoundation.h>

@interface GPUVideoController ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVAssetWriter *assetWriter;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation GPUVideoController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建一个预览图层
    AVCaptureVideoPreviewLayer *preLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    preLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:preLayer];
    
    [self.captureSession startRunning];
    
    [self setButton];
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

- (void)captureButtonClick:(UIButton *)sender {
    AVAssetWriterStatus currentStatus = self.assetWriter.status;
    
    if (currentStatus == AVAssetWriterStatusWriting) {
        [self.assetWriter finishWritingWithCompletionHandler:^{
            NSLog(@"finishWritingWithCompletionHandler");
        }];
        
    } else {
        
        [self.assetWriter startWriting];
    }
    
//    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)changeDevice:(UIButton *)sender {
    AVCaptureDevicePosition position;
    
    AVCaptureDevice *currentDevice = self.videoInput.device;
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
    
    [self.captureSession beginConfiguration];
    [self.captureSession removeInput:self.videoInput];
    if ([self.captureSession canAddInput:changeInput]) {
        [self.captureSession addInput:changeInput];
        self.videoInput = changeInput;
    }
    [self.captureSession commitConfiguration];
}

//- (void)refreshTime {
//    NSInteger totalSecond = self.output.recordedDuration.value / self.output.recordedDuration.timescale;
//    
//    self.assetWriter.
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
//}

#pragma mark
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CMTime lastSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    AVAssetWriterStatus currentStatus = self.assetWriter.status;
    
    if (currentStatus == AVAssetWriterStatusWriting) {
//        [self.assetWriter startWriting];
        [self.assetWriter startSessionAtSourceTime:lastSampleTime];
        
    } else if (currentStatus == AVAssetWriterStatusFailed) {
        NSLog(@"AVAssetWriterStatusFailed");
    } else {
        NSLog(@"%ld",currentStatus);
    }
}

#pragma mark
- (AVCaptureDeviceInput *)videoInput {
    if (!_videoInput) {
        //默认摄像头输入设备，后置摄像头
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        _videoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    }
    return _videoInput;
}

- (AVAssetWriter *)assetWriter {
    if (!_assetWriter) {
        NSString *path = [kDocumentPath stringByAppendingPathComponent:@"myGPUVideo.mov"];
        NSURL *url = [NSURL fileURLWithPath:path];
        
//        _assetWriter = [AVAssetWriter assetWriterWithURL:url fileType:AVFileTypeQuickTimeMovie error:nil];
        _assetWriter = [AVAssetWriter assetWriterWithURL:url fileType:AVFileTypeMPEG4 error:nil];
        
        AVAssetWriterInput *videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:nil];
        videoInput.expectsMediaDataInRealTime = YES;
        AVAssetWriterInput *audioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:nil];
        audioInput.expectsMediaDataInRealTime = YES;
        
        if ([_assetWriter canAddInput:videoInput]) {
            [_assetWriter addInput:videoInput];
        }
        if ([_assetWriter canAddInput:audioInput]) {
            [_assetWriter addInput:audioInput];
        }
    }
    return _assetWriter;
}

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        
        AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
        
        AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        [videoOutput setAlwaysDiscardsLateVideoFrames:YES];
        [videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        
        AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc] init];
        [audioOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        
        _captureSession = [[AVCaptureSession alloc] init];
        
        if ([_captureSession canAddInput:self.videoInput]) {
            [_captureSession addInput:self.videoInput];
        }
        if ([_captureSession canAddInput:audioInput]) {
            [_captureSession addInput:audioInput];
        }
        
        if ([_captureSession canAddOutput:videoOutput]) {
            [_captureSession addOutput:videoOutput];
        }
        if ([_captureSession canAddOutput:audioOutput]) {
            [_captureSession addOutput:audioOutput];
        }
        
    }
    return _captureSession;
}

//- (CADisplayLink *)displayLink {
//    if (!_displayLink) {
//        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(refreshTime)];
//        _displayLink.frameInterval = 60;
//    }
//    return _displayLink;
//}

//- (UILabel *)timeLabel {
//    if (!_timeLabel) {
//        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, Screen_W, 21)];
//        _timeLabel.textAlignment = NSTextAlignmentCenter;
//        _timeLabel.backgroundColor = [UIColor clearColor];
//        _timeLabel.textColor = [UIColor whiteColor];
//        _timeLabel.font = [UIFont boldSystemFontOfSize:18];
//    }
//    return _timeLabel;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

