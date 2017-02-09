//
//  DDImageBrowserVideo.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/2/9.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "DDImageBrowserVideo.h"

@interface DDImageBrowserVideo ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) AVPlayer *avPlayer;

@property (nonatomic, strong) UIView *bottomView;


@end

@implementation DDImageBrowserVideo

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_imageView];
    
    [[PHImageManager defaultManager] requestImageDataForAsset:self.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        
        UIImage *result = [UIImage imageWithData:imageData];
        _imageView.image = result;
    }];
    [self addButton];
}

- (void)addButton {
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 50, CGRectGetWidth(self.view.frame), 50)];
    _bottomView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    [self.view addSubview:_bottomView];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 100, 40)];
    [backButton setTitle:@"取消" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:backButton];
    
    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(200, 0, 100, 40)];
    [playButton setTitle:@"播放" forState:UIControlStateNormal];
    [playButton setTitle:@"暂停" forState:UIControlStateSelected];
    [playButton addTarget:self action:@selector(videoPaly:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:playButton];
}

#pragma mark
- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)videoPaly:(UIButton *)buton {
    [self.view bringSubviewToFront:self.bottomView];
    
    if (buton.selected) {
        [self.avPlayer pause];
    } else {
        [self.avPlayer play];
    }
    
    buton.selected = !buton.selected;
}

#pragma mark
- (AVPlayer *)avPlayer {
    if (!_avPlayer) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        
        [[PHImageManager defaultManager] requestPlayerItemForVideo:self.asset options:options resultHandler:^(AVPlayerItem * playerItem, NSDictionary * info) {
            
            _avPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
            
            AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
            playerLayer.frame = self.view.bounds;
            playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            
            [self.view.layer addSublayer:playerLayer];
        }];
    }
    return _avPlayer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
