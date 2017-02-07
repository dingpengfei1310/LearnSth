//
//  PLPlayerViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "PLPlayerViewController.h"

#import <PLPlayerKit/PLPlayerKit.h>

@interface PLPlayerViewController ()<PLPlayerDelegate>

@property (nonatomic, strong) PLPlayer *player;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation PLPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    self.player.playerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.player.playerView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.imageView];
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.live.bigpic]];
    UIImage *image = [UIImage imageWithData:data];
    UIImage *blurImage = [image applyBlurWithRadius:50.0 tintColor:[UIColor colorWithWhite:.5 alpha:.1] saturationDeltaFactor:0.9 maskImage:nil];
    self.imageView.image = blurImage;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backButtonImage"] style:UIBarButtonItemStylePlain target:self action:@selector(dismisss:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self navigationBarColorClear];
    [self.player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self navigationBarColorRestore];
    [self.player stop];
}

- (void)dismisss:(UIBarButtonItem *)sender {
    [self.player stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
- (void)player:(PLPlayer *)player statusDidChange:(PLPlayerStatus)state {
    if (state == PLPlayerStatusPlaying) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.imageView removeFromSuperview];
        });
    }
}

#pragma mark
- (PLPlayer *)player {
    if (!_player) {
        PLPlayerOption *option = [PLPlayerOption defaultOption];
        [option setOptionValue:@15 forKey:PLPlayerOptionKeyTimeoutIntervalForMediaPackets];
        
        NSURL *url = [NSURL URLWithString:self.live.flv];
        
        _player = [PLPlayer playerWithURL:url option:option];
        _player.delegate = self;
        
        _player.backgroundPlayEnable = YES;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    return _player;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
