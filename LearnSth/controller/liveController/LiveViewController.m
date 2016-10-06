//
//  LiveViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/28.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "LiveViewController.h"

#import <PLCameraStreamingKit/PLCameraStreamingKit.h>

@interface LiveViewController ()

@property (nonatomic, strong) PLCameraStreamingSession *session;

@end

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if TARGET_IPHONE_SIMULATOR

#elif TARGET_OS_IPHONE
    PLVideoCaptureConfiguration *videoCaptureConfiguration = [PLVideoCaptureConfiguration defaultConfiguration];
    PLAudioCaptureConfiguration *audioCaptureConfiguration = [PLAudioCaptureConfiguration defaultConfiguration];
    PLVideoStreamingConfiguration *videoStreamingConfiguration = [PLVideoStreamingConfiguration defaultConfiguration];
    PLAudioStreamingConfiguration *audioStreamingConfiguration = [PLAudioStreamingConfiguration defaultConfiguration];
    
    self.session = [[PLCameraStreamingSession alloc] initWithVideoCaptureConfiguration:videoCaptureConfiguration audioCaptureConfiguration:audioCaptureConfiguration videoStreamingConfiguration:videoStreamingConfiguration audioStreamingConfiguration:audioStreamingConfiguration stream:nil videoOrientation:AVCaptureVideoOrientationPortrait];
#endif
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.view addSubview:self.session.previewView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
