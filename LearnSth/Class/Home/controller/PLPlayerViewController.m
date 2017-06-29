//
//  PLPlayerViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "PLPlayerViewController.h"
#import "LiveInfoViewController.h"
#import "LiveModel.h"

#import <PLPlayerKit/PLPlayerKit.h>

@interface PLPlayerViewController () <PLPlayerDelegate> {
    CGFloat viewW;
    CGFloat viewH;
}

@property (nonatomic, strong) LiveModel *liveModel;

@property (nonatomic, strong) PLPlayer *player;
@property (nonatomic, strong) UIImageView *foregroundView;

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, assign) CGPoint lastPanPoint;

@end

//const NSInteger PlayerViewTag = 99999;
const CGFloat PlayerViewScale = 0.4;//缩小后的view宽度占屏幕宽度的比例

@implementation PLPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    viewW = CGRectGetWidth(self.view.frame);
    viewH = CGRectGetHeight(self.view.frame);
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissPlayerController)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(smallWindow:)];
    
    if (self.index < self.liveArray.count) {
        self.liveModel = self.liveArray[self.index];
        self.title = self.liveModel.myname;
        
        [self.view addSubview:self.player.playerView];
        [self showForegroundView];
        [self addOriginalGesture];
        
        [self.player play];
        self.player.playerView.gestureRecognizers = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self navigationBarColorClear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self navigationBarColorRestore];
}

#pragma mark
- (void)showForegroundView {
    if (!_foregroundView) {
        _foregroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _foregroundView.contentMode = UIViewContentModeScaleAspectFill;
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithFrame:self.view.bounds];
        effectView.effect = blurEffect;
        [_foregroundView addSubview:effectView];
        
        [self.view addSubview:_foregroundView];
    }
    
    [_foregroundView sd_setImageWithURL:[NSURL URLWithString:self.liveModel.bigpic]];
}

- (void)addOriginalGesture {
    UISwipeGestureRecognizer *dismissGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPlayerController)];
    dismissGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:dismissGesture];
    
    UISwipeGestureRecognizer *nextGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextLive)];
    nextGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:nextGesture];
}

- (void)dismissPlayerController {
    [self.player stop];
    if (self.PlayerDismissBlock) {
        self.PlayerDismissBlock();
    }
}

- (void)smallWindow:(UIBarButtonItem *)sender {
    [self.player.playerView removeFromSuperview];
    [self.window addSubview:self.player.playerView];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.player.playerView.frame = CGRectMake((1 - PlayerViewScale) * viewW, 64, viewW * PlayerViewScale, viewH * PlayerViewScale);
    } completion:^(BOOL finished) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePlayerView:)];
        [self.player.playerView addGestureRecognizer:panGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlayerView:)];
        [self.player.playerView addGestureRecognizer:tapGesture];
    }];
    
    LiveInfoViewController *controller = [[LiveInfoViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.liveModel = self.liveModel;
    [self.navigationController pushViewController:controller animated:NO];
    controller.LiveInfoDismissBlock = ^{
        [self backToRootController];
    };
}

- (void)movePlayerView:(UIPanGestureRecognizer *)gestureRecognizer {
    UIGestureRecognizerState state = gestureRecognizer.state;
    CGPoint point = [gestureRecognizer locationInView:self.window];
    
    if (state == UIGestureRecognizerStateChanged) {
        CGFloat change_X = point.x - self.lastPanPoint.x;
        CGFloat change_Y = point.y - self.lastPanPoint.y;
        
        CGPoint center = self.player.playerView.center;
        
        CGFloat Center_X = center.x + change_X;
        CGFloat Center_Y = center.y + change_Y;
        CGFloat scale = PlayerViewScale * 0.5;
        
        if (Center_X < viewW * scale) {
            Center_X = viewW * scale;
        } else if (Center_X > viewW * (1 - scale)) {
            Center_X = viewW * (1 - scale);
        }
        
        if (Center_Y < viewH * scale) {
            Center_Y = viewH * scale;
        } else if (Center_Y > viewH * (1 - scale)) {
            Center_Y = viewH * (1 - scale);
        }
        
        self.player.playerView.center = CGPointMake(Center_X, Center_Y);
    }
    
    self.lastPanPoint = point;
}

- (void)tapPlayerView:(UITapGestureRecognizer *)gestureRecognizer {
    [self backToRootController];
}

//返回到这个页面的处理
- (void)backToRootController {
    [UIView animateWithDuration:0.5 animations:^{
        self.player.playerView.frame = self.view.bounds;
    } completion:^(BOOL finished) {
        [self.player.playerView removeFromSuperview];
        [self.view addSubview:self.player.playerView];
        
        [self.navigationController popToRootViewControllerAnimated:NO];
    }];
}

- (void)nextLive {
    if (self.index < self.liveArray.count - 1) {
        self.index ++;
        self.liveModel = self.liveArray[self.index];
        self.title = self.liveModel.myname;
        [self showForegroundView];
        
        NSURL *url = [NSURL URLWithString:self.liveModel.flv];
        [self.player playWithURL:url];
    } else {
        [self showError:@"没有更多数据"];
    }
}

#pragma mark
- (void)player:(PLPlayer *)player statusDidChange:(PLPlayerStatus)state {
    if (state == PLPlayerStatusPlaying) {
        [self.foregroundView removeFromSuperview];
        self.foregroundView = nil;
    }
}

#pragma mark
- (PLPlayer *)player {
    if (!_player) {
        PLPlayerOption *option = [PLPlayerOption defaultOption];
//        [option setOptionValue:@1 forKey:PLPlayerOptionKeyVideoToolbox];
        
        NSURL *url = [NSURL URLWithString:self.liveModel.flv];
        _player = [PLPlayer playerWithURL:url option:option];
        _player.delegate = self;
        
        _player.backgroundPlayEnable = YES;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    return _player;
}

- (UIWindow *)window {
    if (!_window) {
        _window = [UIApplication sharedApplication].keyWindow;
    }
    return _window;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self showAlertWithTitle:nil message:@"收到内存警告" operationTitle:@"确定" operation:nil];
}

@end
