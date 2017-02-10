//
//  DDImageBrowserVideo.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/2/9.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "DDImageBrowserVideo.h"

#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface DDImageBrowserVideo ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end

@implementation DDImageBrowserVideo

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
//    [self.view addSubview:_imageView];
//    
//    [[PHImageManager defaultManager] requestImageDataForAsset:self.asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
//        
//        UIImage *result = [UIImage imageWithData:imageData];
//        _imageView.image = result;
//    }];
    
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    
    [[PHImageManager defaultManager] requestPlayerItemForVideo:self.asset options:options resultHandler:^(AVPlayerItem *playerItem, NSDictionary *info) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            _player = [AVPlayer playerWithPlayerItem:playerItem];
            
            [self.view.layer addSublayer:self.playerLayer];
            [self addButton];
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)addButton {
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
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
}

#pragma mark
- (void)back {
    [self.player pause];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)videoPaly:(UIButton *)buton {
    if (buton.selected) {
        [self.player pause];
    } else {
        [self.player play];
    }
    
    buton.selected = !buton.selected;
}

#pragma mark
- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer.frame = self.view.bounds;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    return _playerLayer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
