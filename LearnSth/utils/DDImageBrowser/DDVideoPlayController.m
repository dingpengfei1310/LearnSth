//
//  DDVideoPlayController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/16.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "DDVideoPlayController.h"

#import <AVFoundation/AVFoundation.h>

@interface DDVideoPlayController ()

@property (nonatomic, strong) AVPlayer *player;

@end

@implementation DDVideoPlayController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:nil];
    _player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    [self.view.layer addSublayer:playerLayer];
    
    [_player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
