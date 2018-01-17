//
//  VideoPlayerController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/13.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "VideoPlayerController.h"
#import "VideoPlayerView.h"
#import "AppDelegate.h"

#import <Photos/Photos.h>

@interface VideoPlayerController ()

@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL isLandscape;//是否横屏

@property (nonatomic, strong) VideoPlayerView *playerView;

@end

@implementation VideoPlayerController

- (BOOL)prefersStatusBarHidden {
    if (self.isLandscape) {
        return self.statusBarHidden;
    }
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, 20)];
//    statusBarView.backgroundColor = [UIColor blackColor];
//    [self.view addSubview:statusBarView];
    
    if (self.asset) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        
        [[PHImageManager defaultManager] requestPlayerItemForVideo:self.asset options:options resultHandler:^(AVPlayerItem *playerItem, NSDictionary *info) {
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                _playerView = [[VideoPlayerView alloc] initWithTitle:self.title playerItem:playerItem];
                [self setPlayerBlock];
                [self.view addSubview:_playerView];
            });
        }];
    } else {
        _playerView = [[VideoPlayerView alloc] initWithTitle:self.title filePath:_fileUrl];
        
        [self setPlayerBlock];
        [self.view addSubview:_playerView];
    }
}

- (void)setPlayerBlock {
    __weak typeof(self) wSelf = self;
    
    _playerView.BackBlock = ^{
        [wSelf backToParentController];
    };
    
    _playerView.FullScreenBlock = ^{
        [wSelf rotationPlayer];
    };
    
    _playerView.TapGestureBlock = ^{
        wSelf.statusBarHidden = !wSelf.statusBarHidden;
        [wSelf setNeedsStatusBarAppearanceUpdate];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.isAutorotate = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.isAutorotate = NO;
}

#pragma mark
- (void)backToParentController {
    if (self.isLandscape) {
        [self rotationPlayer];
        
    } else {
        [self.playerView pausePlayer];
        self.DismissBlock ? self.DismissBlock() : 0;
    }
}

- (void)rotationPlayer {
    self.isLandscape = !self.isLandscape;
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    if (self.isLandscape) {//要转成横屏
        orientation = UIInterfaceOrientationLandscapeRight;
    }
    
    NSNumber *orientationTarget = [NSNumber numberWithInt:orientation];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
}

#pragma mark - 屏幕旋转
- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    
    //横屏:==。。。。竖屏:!=
    self.isLandscape = (newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
