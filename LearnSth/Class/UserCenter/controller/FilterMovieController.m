//
//  FilterMovieController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/1/21.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "FilterMovieController.h"
#import "FilterCollectionView.h"
#import "GPUImage.h"

@interface FilterMovieController ()

@property (nonatomic, strong) GPUImageView *videoView;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageFilter *currentFilter;

@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic, strong) GPUImageFilterGroup *groupFilter;

@property (nonatomic, strong) NSArray *imageFilters;

@property (nonatomic, strong) NSString *moviePath;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, assign) BOOL isRecording;

@end

@implementation FilterMovieController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isRecording = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkAuthorizationStatusOnVideo];
}

- (void)showVideoView {
    
    self.imageFilters = @[
//                          @{@"name":@"美颜",@"className":[GPUImageFilterGroup class]},
                          @{@"name":@"明亮",@"className":[GPUImageBrightnessFilter class]},
                          @{@"name":@"素描",@"className":[GPUImageSketchFilter class]},
                          @{@"name":@"褐色/怀旧",@"className":[GPUImageSepiaFilter class]},
                          @{@"name":@"色彩丢失",@"className":[GPUImageColorPackingFilter class]},
                          @{@"name":@"浮雕3D",@"className":[GPUImageEmbossFilter class]},
                          @{@"name":@"像素",@"className":[GPUImagePixellateFilter class]},
                          @{@"name":@"同心圆像素",@"className":[GPUImagePolarPixellateFilter class]},//GPUImagePolarPixellateFilter.GPUImagePixellateFilter
                          @{@"name":@"卡通",@"className":[GPUImageSmoothToonFilter class]},//GPUImageSmoothToonFilter.GPUImageToonFilter
                          @{@"name":@"反色",@"className":[GPUImageColorInvertFilter class]},
                          @{@"name":@"灰度",@"className":[GPUImageGrayscaleFilter class]},
                          @{@"name":@"凸起失真",@"className":[GPUImageBulgeDistortionFilter class]},
                          @{@"name":@"收缩失真",@"className":[GPUImagePinchDistortionFilter class]},
                          @{@"name":@"伸展失真",@"className":[GPUImageStretchDistortionFilter class]},
                          @{@"name":@"收缩失真",@"className":[GPUImagePinchDistortionFilter class]},
                          @{@"name":@"水晶球",@"className":[GPUImageGlassSphereFilter class]},
                          @{@"name":@"像素平均值",@"className":[GPUImageAverageColor class]},
//                          @{@"name":@"纯色",@"className":[GPUImageSolidColorGenerator class]},
                          @{@"name":@"亮度平均",@"className":[GPUImageLuminosity class]},
                          @{@"name":@"抑制",@"className":[GPUImageNonMaximumSuppressionFilter class]},
                          @{@"name":@"高斯模糊",@"className":[GPUImageGaussianBlurFilter class]},
                          @{@"name":@"高斯模糊，部分清晰",@"className":[GPUImageGaussianSelectiveBlurFilter class]},
                          @{@"name":@"盒状模糊",@"className":[GPUImageBoxBlurFilter class]},
                          @{@"name":@"条纹模糊",@"className":[GPUImageTiltShiftFilter class]},
                          @{@"name":@"中间值",@"className":[GPUImageMedianFilter class]},
                          ];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@-FilterVideo.mov",dateString];
    self.moviePath = [kDocumentPath stringByAppendingPathComponent:fileName];
    
    
    /////////////////////////////////
    // 创建滤镜：磨皮，美白，组合滤镜
    GPUImageFilterGroup *groupFilter = [[GPUImageFilterGroup alloc] init];
    
    // 磨皮滤镜
    GPUImageBilateralFilter *bilateralFilter = [[GPUImageBilateralFilter alloc] init];
    [groupFilter addTarget:bilateralFilter];
    
    // 美白滤镜
    GPUImageBrightnessFilter *brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    [groupFilter addTarget:brightnessFilter];
    
    // 设置滤镜组链
    [bilateralFilter addTarget:brightnessFilter];
    [groupFilter setInitialFilters:@[bilateralFilter]];
    groupFilter.terminalFilter = brightnessFilter;
    self.groupFilter = groupFilter;
    
    
    GPUImageView *videoView = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, Screen_W, Screen_H)];
    [groupFilter addTarget:videoView];
    [self.videoCamera addTarget:groupFilter];
    
    //默认，不带滤镜
//    [self.videoCamera addTarget:videoView];
    
    
    [self.view addSubview:videoView];
    _videoView = videoView;
    
    [self.videoCamera startCameraCapture];
    
    [self setButtonAndTimeLabel];
}

- (void)checkAuthorizationStatusOnVideo {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusAuthorized) {
        [self checkAuthorizationStatusOnAudio];
    } else if (status == AVAuthorizationStatusDenied) {
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
        [self showVideoView];
    } else if (status == AVAuthorizationStatusDenied) {
        [self showAuthorizationStatusDeniedAlertMessage:@"没有麦克风访问权限" Cancel:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        } operation:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
    } else if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            granted ? [self showVideoView] : [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

#pragma mark
- (void)setButtonAndTimeLabel {
    CGFloat bottomHeight = 100;
    
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
    
    [self.view addSubview:self.timeLabel];
    
    FilterCollectionView *filterView = [[FilterCollectionView alloc] initWithFrame:CGRectMake(0, Screen_H - 50, Screen_W, 50)];
    filterView.filters = self.imageFilters;
    filterView.FilterSelect = ^(NSInteger index){
        [self changeFilterWith:index];
    };
    [self.view addSubview:filterView];
}

- (void)dismiss:(UIButton *)sender {
    [self.videoCamera stopCameraCapture];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)changeDevice:(UIButton *)sender {
    [self.videoCamera rotateCamera];
}

- (void)changeFilterWith:(NSInteger)index {
    
    NSDictionary *filterInfo = self.imageFilters[index];
    Class filterClass = filterInfo[@"className"];
    if ([self.currentFilter isKindOfClass:filterClass]) {
        return;
    }
    
    self.groupFilter = nil;
    self.currentFilter = [[filterClass alloc] init];
    
    if (self.isRecording) {
        [self.videoCamera pauseCameraCapture];
        
        [self.currentFilter removeAllTargets];
        [self.currentFilter addTarget:self.movieWriter];
        [self.currentFilter addTarget:self.videoView];
        
        [self.videoCamera removeAllTargets];
        [self.videoCamera addTarget:self.currentFilter];
        self.videoCamera.audioEncodingTarget = self.movieWriter;
        
        [self.videoCamera resumeCameraCapture];
        
    } else {
        [self.currentFilter removeAllTargets];
        [self.currentFilter addTarget:self.videoView];
        
        [self.videoCamera removeAllTargets];
        [self.videoCamera addTarget:self.currentFilter];
    }
}

- (void)captureButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        unlink([self.moviePath UTF8String]); // 如果已经存在文件，AVAssetWriter会有异常，删除旧文件
        if (self.groupFilter) {
            [self.groupFilter addTarget:self.movieWriter];
        } else {
            [self.currentFilter addTarget:self.movieWriter];
        }
        
        self.videoCamera.audioEncodingTarget = self.movieWriter;
        [self.movieWriter startRecording];
        _isRecording = YES;
        
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    } else {
        if (self.groupFilter) {
            [self.groupFilter removeTarget:self.movieWriter];
        } else {
            [self.currentFilter removeTarget:self.movieWriter];
        }
        
        _videoCamera.audioEncodingTarget = nil;
        [self.movieWriter finishRecording];
        _isRecording = NO;
        
        [self showAlertWithTitle:@"提示" message:@"是否保存到手机？" cancel:nil operation:^{
            [self loading];
            UISaveVideoAtPathToSavedPhotosAlbum(self.moviePath, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
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
        _currentFilter = [[GPUImageBrightnessFilter alloc] init];
    }
    return _currentFilter;
}

- (GPUImageMovieWriter *)movieWriter {
    if (!_movieWriter) {
        NSURL *url = [NSURL fileURLWithPath:self.moviePath];
//        1920x1080 1280x720  960x540 640x480
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:url size:CGSizeMake(720.0, 1280.0)];
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
