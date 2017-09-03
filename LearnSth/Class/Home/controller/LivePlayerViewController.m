//
//  LivePlayerViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/9/3.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "LivePlayerViewController.h"
#import "LiveModel.h"

//#import <IJKMediaFramework/IJKMediaFramework.h>

@interface LivePlayerViewController ()

//@property (atomic, retain) id <IJKMediaPlayback> player;

@end

@implementation LivePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.liveModel.myname;
    
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissPlayerController)];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(smallWindow:)];
    
//    [IJKFFMoviePlayerController setLogReport:YES];
//    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
//    
//    [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
//    
//    //直播视频
//    NSURL *url = [NSURL URLWithString:_liveModel.flv];
//    
//    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
//    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:options];
//    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//    self.player.view.frame = self.view.bounds;
//    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
//    self.player.shouldAutoplay = YES;
//    
//    self.view.autoresizesSubviews = YES;
//    [self.view addSubview:self.player.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self navigationBarColorClear];
    
//    [self.player prepareToPlay];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self navigationBarColorRestore];
}

#pragma mark
- (void)dismissPlayerController {
    if (self.PlayerDismissBlock) {
        self.PlayerDismissBlock();
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
