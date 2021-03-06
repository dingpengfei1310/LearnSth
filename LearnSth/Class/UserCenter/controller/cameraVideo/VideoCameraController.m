//
//  VideoCaptureController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/1/19.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "VideoCameraController.h"
#import <AVFoundation/AVFoundation.h>

@interface VideoCameraController ()<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;

@property (nonatomic, strong) NSString *movieName;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation VideoCameraController

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

#pragma mark
- (void)showVideoPreviewLayer {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    self.movieName = [NSString stringWithFormat:@"%@-Video.mov",dateString];
    
    //创建一个预览图层
    AVCaptureVideoPreviewLayer *preLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    preLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:preLayer];
    
    [self.captureSession startRunning];
    
    [self.view addSubview:self.timeLabel];
    [self setButton];
    
//    SceneGameView *gameView = [[SceneGameView alloc] initWithFrame:CGRectMake(0, 64, 320, 320)];
//    [self.view addSubview:gameView];
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"boss_attack" withExtension:@"dae"];
//    [gameView addModelFile:url position:SCNVector3Make(0, 0, -1000)];
}

- (void)checkAuthorizationStatusOnVideo {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusAuthorized) {
        [self checkAuthorizationStatusOnAudio];
    } else if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
        [self showAuthorizationStatusDeniedAlertMessage:@"没有相机访问权限"];
        
    } else if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                granted ? [self checkAuthorizationStatusOnAudio] : [self dismissViewControllerAnimated:YES completion:nil];
            });
        }];
    }
}

- (void)checkAuthorizationStatusOnAudio {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    if (status == AVAuthorizationStatusAuthorized) {
        [self showVideoPreviewLayer];
    } else if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
        [self showAuthorizationStatusDeniedAlertMessage:@"没有麦克风访问权限"];
        
    } else if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                granted ? [self showVideoPreviewLayer] : [self dismissViewControllerAnimated:YES completion:nil];
            });
        }];
    }
}

#pragma mark
- (void)setButton {
    CGFloat viewW = self.view.frame.size.width;
    CGFloat viewH = self.view.frame.size.height;
    CGFloat bottomHeight = 70;
    
    UIButton *dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 42)];
    dismissButton.center = CGPointMake(viewW * 0.5 - viewW * 0.2, viewH - bottomHeight);
    UIImage *originalImage = [UIImage imageNamed:@"backButton"];
    UIImage *image = [UIImage imageWithCGImage:originalImage.CGImage
                                         scale:2.0
                                   orientation:UIImageOrientationLeft];
    [dismissButton setImage:image forState:UIControlStateNormal];
    [dismissButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dismissButton];
    
    UIButton *captureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 49, 49)];
    captureButton.center = CGPointMake(viewW * 0.5, viewH - bottomHeight);
    [captureButton setImage:[UIImage imageNamed:@"redSpot"] forState:UIControlStateNormal];
    [captureButton addTarget:self action:@selector(captureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:captureButton];
    
    UIButton *changeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 42)];
    changeButton.center = CGPointMake(viewW * 0.5 + viewW * 0.2, viewH - bottomHeight);
    [changeButton setTitle:@"切换" forState:UIControlStateNormal];
    [changeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [changeButton addTarget:self action:@selector(changeDevice:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeButton];
}

- (void)dismiss:(UIButton *)sender {
    [self.movieFileOutput stopRecording];
    [self.captureSession stopRunning];
    [self.displayLink invalidate];
    
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
    NSString *path = [KDocumentPath stringByAppendingPathComponent:self.movieName];
    
    if (self.movieFileOutput.recording) {
        [self.movieFileOutput stopRecording];
        
        [self.displayLink invalidate];
        self.displayLink = nil;
        self.timeLabel.text = nil;
        
        [self showAlertWithTitle:nil message:@"是否保存到手机？" cancel:nil operation:^{
            [self loading];
            UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
//            [self compressVideo];//压缩视频
        }];
        
        return;
    }
    
    //设置录制视频保存的路径
    
    NSURL *url = [NSURL fileURLWithPath:path];
    [self.movieFileOutput startRecordingToOutputFileURL:url recordingDelegate:self];
    
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [self hideHUD];
    [self showSuccess:@"保存成功"];
    
    [self dismiss:nil];
}

- (void)refreshTime {
    CMTime time = self.movieFileOutput.recordedDuration;
    NSInteger totalSecond = time.value / time.timescale;
    
    NSInteger hour = 0;
    NSInteger minute = 0;
    NSInteger second = 0;
    
    if (totalSecond >= 3600) {
        hour = totalSecond / 3600;
        minute = (totalSecond % 3600) / 600;
        second = totalSecond % 60;
        self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hour,minute,second];
    } else {
        minute = totalSecond / 60;
        second = totalSecond % 60;
        self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hour,minute,second];
    }
}

- (void)compressVideo {
    NSString *path = [KDocumentPath stringByAppendingPathComponent:self.movieName];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
    
    NSString *compressName = [NSString stringWithFormat:@"Compress%@",self.movieName];
    NSString *compressPath = [KDocumentPath stringByAppendingPathComponent:compressName];
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = [NSURL fileURLWithPath:compressPath];
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        AVAssetExportSessionStatus status = exportSession.status;
        NSString *message = (status == AVAssetExportSessionStatusCompleted) ? @"压缩成功" : @"压缩失败";
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHUD];
            [self showSuccess:message];
        });
    }];
}

//#pragma mark
//- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
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

- (AVCaptureMovieFileOutput *)movieFileOutput {
    if (!_movieFileOutput) {
        _movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    }
    return _movieFileOutput;
}

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        
        //创建麦克风设备，输入设备
        AVCaptureDevice *deviceAudio = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput *inputAudio = [AVCaptureDeviceInput deviceInputWithDevice:deviceAudio error:nil];
        
        _captureSession = [[AVCaptureSession alloc] init];
//        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
        
        //将输入输出设备添加到会话中
        if ([_captureSession canAddInput:self.videoDeviceInput]) {
            [_captureSession addInput:self.videoDeviceInput];
        }
        if ([_captureSession canAddInput:inputAudio]) {
            [_captureSession addInput:inputAudio];
        }
        if ([_captureSession canAddOutput:self.movieFileOutput]) {
            [_captureSession addOutput:self.movieFileOutput];
        }
    }
    return _captureSession;
}

- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(refreshTime)];
        _displayLink.frameInterval = 60;
    }
    return _displayLink;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 21)];
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
