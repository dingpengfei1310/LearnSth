//
//  VideoScanController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/2/14.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "VideoScanController.h"
#import "GPUImage.h"
#import <Photos/Photos.h>

@interface VideoScanController ()<GPUImageMovieDelegate>

//@property (nonatomic, strong) GPUImageMovie *movie;

@end

@implementation VideoScanController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self setBackgropundImage];
    
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    
    [[PHImageManager defaultManager] requestPlayerItemForVideo:self.asset options:options resultHandler:^(AVPlayerItem *playerItem, NSDictionary *info) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            GPUImageView *videoView = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, Screen_W, Screen_H)];
            [self.view addSubview:videoView];
            
            GPUImageMovie *movieFile = [[GPUImageMovie alloc] initWithPlayerItem:playerItem];
            movieFile.delegate = self;
            movieFile.playAtActualSpeed = YES;
            [movieFile addTarget:videoView];
            [movieFile startProcessing];
            
            [self addButton];
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didCompletePlayingMovie {
    NSLog(@"didCompletePlayingMovie");
}

#pragma mark
- (void)setBackgropundImage {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:imageView];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    options.synchronous = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:self.asset
                                               targetSize:CGSizeZero
                                              contentMode:PHImageContentModeAspectFit
                                                  options:options
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                imageView.image = result;
                                            }];
}

- (void)addButton {
    CGFloat viewWidth = Screen_W;
    CGFloat viewHeight = Screen_H;
    CGFloat buttonWidth = 50;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight - 50, viewWidth, 50)];
    bottomView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
    [self.view addSubview:bottomView];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, 30)];
    backButton.center = CGPointMake(viewWidth / 4, 25);
    [backButton setTitle:@"取消" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:backButton];
    
//    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, 30)];
//    playButton.center = CGPointMake(viewWidth / 4 * 3, 25);
//    [playButton setTitle:@"播放" forState:UIControlStateNormal];
//    [playButton setTitle:@"暂停" forState:UIControlStateSelected];
//    [playButton addTarget:self action:@selector(videoPaly:) forControlEvents:UIControlEventTouchUpInside];
//    [bottomView addSubview:playButton];
//    _playButton = playButton;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
