//
//  FilterMovieController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/1/21.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "FilterMovieController.h"
#import "GPUImage.h"

@interface FilterMovieController ()

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageFilter *currentFilter;

@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;

@property (nonatomic, strong) NSString *MoviePath;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation FilterMovieController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.MoviePath = [kDocumentPath stringByAppendingPathComponent:@"FilterVideo.mov"];
    
    GPUImageView *filteredVideoView = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, Screen_W, Screen_H)];
    [self.videoCamera addTarget:self.currentFilter];
    [self.currentFilter addTarget:filteredVideoView];
    [self.view addSubview:filteredVideoView];
    
    [self.videoCamera startCameraCapture];
    
    [self.view addSubview:self.timeLabel];
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
    [self.videoCamera stopCameraCapture];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)changeDevice:(UIButton *)sender {
    [self.videoCamera rotateCamera];
}

- (void)captureButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        unlink([self.MoviePath UTF8String]); // 如果已经存在文件，AVAssetWriter会有异常，删除旧文件
        [self.currentFilter addTarget:self.movieWriter];
        self.videoCamera.audioEncodingTarget = self.movieWriter;
        [self.movieWriter startRecording];
        
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    } else {
        [self.currentFilter removeTarget:self.movieWriter];
        _videoCamera.audioEncodingTarget = nil;
        [self.movieWriter finishRecording];
        
        [self showAlertWithTitle:@"提示" message:@"是否保存到手机？" block:^{
            [self loading];
            UISaveVideoAtPathToSavedPhotosAlbum(self.MoviePath, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
        }];
        
        [self.displayLink invalidate];
        self.displayLink = nil;
        self.timeLabel.text = nil;
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [self hideHUD];
    [self showSuccess:@"保存成功"];
}

- (void)refreshTime {
    CMTime time = self.movieWriter.duration;
    NSInteger totalSecond = time.value / time.timescale;
    
    NSInteger hour = 0;
    NSInteger minute = 0;
    NSInteger second = 0;
    
    if (totalSecond >= 3600) {
        hour = totalSecond / 3600;
        minute = (totalSecond % 3600) / 600;
        second = totalSecond % 60;
    } else if (totalSecond >= 60) {
        minute = totalSecond / 60;
        second = totalSecond % 60;
    } else {
        second = totalSecond % 60;
    }
    
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hour,minute,second];
}

#pragma mark
- (GPUImageVideoCamera *)videoCamera {
    if (!_videoCamera) {
        _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
        _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    }
    return _videoCamera;
}

- (GPUImageFilter *)currentFilter {
    if (!_currentFilter) {
        _currentFilter = [[GPUImageSepiaFilter alloc] init];
    }
    return _currentFilter;
}

- (GPUImageMovieWriter *)movieWriter {
    if (!_movieWriter) {
        NSURL *url = [NSURL fileURLWithPath:self.MoviePath];
        
//        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:url size:CGSizeZero];
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:url size:CGSizeMake(480.0, 640.0)];
        _movieWriter.encodingLiveVideo = YES;
    }
    return _movieWriter;
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
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, Screen_W, 21)];
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

