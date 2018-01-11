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

#import <IJKMediaFramework/IJKMediaPlayer.h>

@interface PLPlayerViewController () {
    CGFloat viewW;
    CGFloat viewH;
}

@property (nonatomic, strong) LiveModel *liveModel;

@property (nonatomic, strong) id<IJKMediaPlayback> player;
@property (nonatomic, strong) UIImageView *foregroundView;

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, assign) CGPoint lastPanPoint;

@property (nonatomic, assign) BOOL statusBarHidden;

@end

//const NSInteger PlayerViewTag = 99999;
const CGFloat PlayerViewScale = 0.4;//缩小后的view宽度占屏幕宽度的比例

@implementation PLPlayerViewController

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    viewW = CGRectGetWidth(self.view.frame);
    viewH = CGRectGetHeight(self.view.frame);
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissPlayerController)];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(smallWindow:)];

    if (self.index < self.liveArray.count) {
        self.liveModel = self.liveArray[self.index];
        self.title = self.liveModel.myname;
        
        [IJKFFMoviePlayerController setLogReport:NO];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_ERROR];
        
        [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
        
        [self playWithUrl:self.liveModel.flv];
    }
}

- (void)playWithUrl:(NSString *)urls {
    if (self.player) {
        [self removeMovieNotificationObservers];
        [self.player.view removeFromSuperview];
        [self.player shutdown];
        self.player = nil;
    }
    
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    NSURL *url = [NSURL URLWithString:urls];
    
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:options];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = self.view.bounds;
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.player.shouldAutoplay = NO;
    
    [self.view addSubview:self.player.view];
    [self.player prepareToPlay];
    [self installMovieNotificationObservers];
    
    [self addOriginalGesture];
    [self showForegroundView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self navigationBarColorClear];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.statusBarHidden = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.player shutdown];
    [self removeMovieNotificationObservers];
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
    if (self.PlayerDismissBlock) {
        self.PlayerDismissBlock();
    }
}

- (void)smallWindow:(UIBarButtonItem *)sender {
    [self.player.view removeFromSuperview];
    [self.window addSubview:self.player.view];

    [UIView animateWithDuration:0.5 animations:^{
        self.player.view.frame = CGRectMake((1 - PlayerViewScale) * viewW, 64, viewW * PlayerViewScale, viewH * PlayerViewScale);
    } completion:^(BOOL finished) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePlayerView:)];
        [self.player.view addGestureRecognizer:panGesture];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlayerView:)];
        [self.player.view addGestureRecognizer:tapGesture];
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

        CGPoint center = self.player.view.center;

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

        self.player.view.center = CGPointMake(Center_X, Center_Y);
    }

    self.lastPanPoint = point;
}

- (void)tapPlayerView:(UITapGestureRecognizer *)gestureRecognizer {
    [self backToRootController];
}

//返回到这个页面的处理
- (void)backToRootController {
    self.player.view.gestureRecognizers = nil;

    [UIView animateWithDuration:0.5 animations:^{
        self.player.view.frame = self.view.bounds;
    } completion:^(BOOL finished) {
        [self.player.view removeFromSuperview];
        [self.view addSubview:self.player.view];

        [self.navigationController popToRootViewControllerAnimated:NO];
    }];
}

- (void)nextLive {
    if (self.index < self.liveArray.count - 1) {
        self.index++;
        self.liveModel = self.liveArray[self.index];
        self.title = self.liveModel.myname;
        [self showForegroundView];
        
        [self playWithUrl:self.liveModel.flv];
        
    } else {
        [self showError:@"没有更多数据"];
    }
}

#pragma mark

- (UIWindow *)window {
    if (!_window) {
        _window = [UIApplication sharedApplication].keyWindow;
    }
    return _window;
}

#pragma mark -

- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
    
    IJKMPMovieLoadState loadState = _player.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        [self.player play];
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    //    MPMoviePlaybackStateStopped,
    //    MPMoviePlaybackStatePlaying,
    //    MPMoviePlaybackStatePaused,
    //    MPMoviePlaybackStateInterrupted,
    //    MPMoviePlaybackStateSeekingForward,
    //    MPMoviePlaybackStateSeekingBackward
    
    switch (_player.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            [self.foregroundView removeFromSuperview];
            self.foregroundView = nil;
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

#pragma mark Install Movie Notifications

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self showAlertWithTitle:nil message:@"收到内存警告" operationTitle:@"确定" operation:nil];
}

@end
