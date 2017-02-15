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

@property (nonatomic, strong) GPUImageMovie *movie;
@property (nonatomic, strong) GPUImageView *videoView;

@property (nonatomic, strong) UIButton *playButton;

@end

@implementation VideoScanController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setBackgropundImage];
    
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:self.asset options:options resultHandler:^(AVAsset * asset, AVAudioMix * audioMix, NSDictionary * _Nullable info) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            _videoView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, Screen_W, Screen_H)];
            [self.view addSubview:_videoView];
            
            _movie = [[GPUImageMovie alloc] initWithAsset:asset];
            _movie.delegate = self;
            _movie.playAtActualSpeed = YES;
            
            [_movie addTarget:_videoView];
            
//            GPUImageFilter *filter = [[GPUImageDissolveBlendFilter alloc] init];
//            [_movie addTarget:filter];
//            [filter addTarget:_videoView];
            
//            UIImage *image = [UIImage imageNamed:@"star"];
//            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//            imageView.center = CGPointMake(Screen_W / 2, Screen_H / 2);
//            GPUImageUIElement *uielement = [[GPUImageUIElement alloc] initWithView:imageView];
//            [uielement addTarget:filter];
//            
//            
//            [filter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
//                [uielement updateWithTimestamp:time];
//            }];
            
            
            
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
    _playButton.selected = NO;
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
    
    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, 30)];
    playButton.center = CGPointMake(viewWidth / 4 * 3, 25);
    [playButton setTitle:@"播放" forState:UIControlStateNormal];
    [playButton setTitle:@"暂停" forState:UIControlStateSelected];
    [playButton addTarget:self action:@selector(videoPaly:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:playButton];
    _playButton = playButton;
}

#pragma mark
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)videoPaly:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [self.movie startProcessing];
    } else {
        [self.movie cancelProcessing];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
