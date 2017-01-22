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
@property (nonatomic, strong) GPUImageFilter *customFilter;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;

@end

@implementation FilterMovieController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setButton];
    
    GPUImageVideoCamera *videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    GPUImageFilter *customFilter = [[GPUImageSepiaFilter alloc] init];
//    GPUImageFilter *customFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"CustomShader"];
    GPUImageView *filteredVideoView = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, Screen_W, Screen_H)];
    
    [self.view addSubview:filteredVideoView];
    
    [videoCamera addTarget:customFilter];
    [customFilter addTarget:filteredVideoView];
    
    [videoCamera startCameraCapture];
    
//    videoCamera.audioEncodingTarget = self.assetWriter;
    
    
//    unlink([pathToMovie UTF8String]); // 如果已经存在文件，AVAssetWriter会有异常，删除旧文件
//    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
//    _movieWriter.encodingLiveVideo = YES;
//    [_filter addTarget:_movieWriter];
//    _videoCamera.audioEncodingTarget = _movieWriter;
//    [_movieWriter startRecording];
    
//
//    [_filter removeTarget:_movieWriter];
//    _videoCamera.audioEncodingTarget = nil;
//    [_movieWriter finishRecording];
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
    
//    UIButton *captureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 49, 49)];
//    captureButton.center = CGPointMake(Screen_W * 0.5, Screen_H - bottomHeight);
//    [captureButton setImage:[UIImage imageNamed:@"redSpot"] forState:UIControlStateNormal];
//    [captureButton addTarget:self action:@selector(captureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:captureButton];
//    
//    UIButton *changeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 42)];
//    changeButton.center = CGPointMake(Screen_W * 0.5 + Screen_W * 0.2, Screen_H - bottomHeight);
//    [changeButton setTitle:@"切换" forState:UIControlStateNormal];
//    [changeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [changeButton addTarget:self action:@selector(changeDevice:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:changeButton];
}

- (void)dismiss:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
