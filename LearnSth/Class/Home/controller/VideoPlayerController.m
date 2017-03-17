//
//  VideoPlayerController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/13.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "VideoPlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@interface VideoPlayerController () {
    id playerTimeObserver;
}

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, assign) BOOL isAutorotate;
@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL isLandscape;//是否横屏

//@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIView *statusBarView;//竖屏时的黑色statusBar
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *rotationButton;

@property (nonatomic, strong) UIProgressView *loadingProgress;//加载进度
@property (nonatomic, strong) UISlider *playProgress;//播放进度

@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;

@property (nonatomic, strong) UIButton *lockButton;

@property (nonatomic, assign) BOOL isSliding;
@property (nonatomic, assign) CGFloat ProgressScale;//进度条的宽度（占总宽度比例）

@property (nonatomic, assign) double totalTime;

//@property (nonatomic, assign) CGPoint lastPoint;

@end

const CGFloat PlayerHeightScale = 0.5;//竖屏时，player高度

@implementation VideoPlayerController
- (BOOL)shouldAutorotate {
    return YES;
//    return self.isAutorotate;
}

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
    
    if (self.urlString) {
        [self.view.layer addSublayer:self.playerLayer];
        [self addPlayerObserver];
        [self initSubView];
        [self addGesture];
    } else {
        if (self.BackBlock) {
            self.BackBlock();
        }
    }
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_player removeTimeObserver:playerTimeObserver];
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

#pragma mark
- (void)initSubView {
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_H, 20)];
    statusBarView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:statusBarView];
    _statusBarView = statusBarView;
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, Screen_W, 30)];
    topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topView];
    _topView = topView;
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [backButton setImage:[UIImage imageNamed:@"backButtonImage"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backButton];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, 200, 30)];
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.textColor = [UIColor whiteColor];
    [topView addSubview:nameLabel];
    nameLabel.text = @"啦啦啦啦";
    
    UIButton *lockButton = [[UIButton alloc] initWithFrame:CGRectMake(40, Screen_W * 0.5 - 20, 40, 40)];
    [lockButton setImage:[UIImage imageNamed:@"playerLockScreen"] forState:UIControlStateNormal];
//    [lockButton setImage:[UIImage imageNamed:@"playerPause"] forState:UIControlStateSelected];
    [lockButton addTarget:self action:@selector(lockScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lockButton];
    _lockButton = lockButton;
    
    //bottomView －－－－－－－－－
    //
    CGFloat playerH = Screen_W * PlayerHeightScale + 20;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, playerH - 44, Screen_W, 44)];
    bottomView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bottomView];
    _bottomView = bottomView;
    
    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [playButton setImage:[UIImage imageNamed:@"playerStart"] forState:UIControlStateNormal];
    [playButton setImage:[UIImage imageNamed:@"playerPause"] forState:UIControlStateSelected];
    [playButton addTarget:self action:@selector(videoPaly) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:playButton];
    _playButton = playButton;
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, Screen_W * self.ProgressScale, 10)];
    progressView.progress = 0.0;
    progressView.center = CGPointMake(Screen_W * 0.5, 44 * 0.5);
    progressView.trackTintColor = [UIColor whiteColor];
    progressView.progressTintColor = KBaseBlueColor;
    [bottomView addSubview:progressView];
    _loadingProgress = progressView;
    
    UISlider *slider = [[UISlider alloc] initWithFrame:progressView.frame];
    slider.maximumTrackTintColor = [UIColor clearColor];
    slider.minimumTrackTintColor = [UIColor clearColor];
    [slider setThumbImage:[UIImage imageNamed:@"playerSliderDot"] forState:UIControlStateNormal];
    [slider addTarget:self action:@selector(playerSeekTo:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    [slider addTarget:self action:@selector(sliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:slider];
    _playProgress = slider;
    
    UILabel *currentSecondsLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(progressView.frame) - 70, 0, 60, 44)];
    currentSecondsLabel.font = [UIFont systemFontOfSize:12];
    currentSecondsLabel.textColor = [UIColor whiteColor];
    currentSecondsLabel.textAlignment = NSTextAlignmentRight;
    [bottomView addSubview:currentSecondsLabel];
    _currentTimeLabel = currentSecondsLabel;
    
    UILabel *totalSecondsLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(progressView.frame) + 10, 0, 60, 44)];
    totalSecondsLabel.font = [UIFont systemFontOfSize:12];
    totalSecondsLabel.textColor = [UIColor whiteColor];
    [bottomView addSubview:totalSecondsLabel];
    _totalTimeLabel = totalSecondsLabel;
    
    UIButton *rotationButton = [[UIButton alloc] initWithFrame:CGRectMake(Screen_W - 40, 0, 40, 40)];
    [rotationButton setImage:[UIImage imageNamed:@"playerFullScreen"] forState:UIControlStateNormal];
    [rotationButton addTarget:self action:@selector(rotationPlayer) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:rotationButton];
    _rotationButton = rotationButton;
}

- (void)addGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPLayer:)];
    [self.view addGestureRecognizer:tap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapOnPLayer:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    [tap requireGestureRecognizerToFail:doubleTap];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipOnPlayer:)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipe];
    
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOnPlayer:)];
//    [self.view addGestureRecognizer:pan];
}

- (void)addPlayerObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidPlayToEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    __weak typeof(self) wSelf = self;
    playerTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        if (!wSelf.isSliding) {
            wSelf.playProgress.value = CMTimeGetSeconds(time);
            wSelf.currentTimeLabel.text = [wSelf timeStringWith:CMTimeGetSeconds(time)];
        }
    }];
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    AVPlayerItem *item = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if (status == AVPlayerStatusReadyToPlay) {
            
            CMTime duration = item.duration;
            [self setMaxDuration:CMTimeGetSeconds(duration)];
            [self videoPaly];
            
            [self hideStatusBar];
        }
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDurationRanges]; // 缓冲时间
        self.loadingProgress.progress = timeInterval / _totalTime;// 更新缓冲条
    }
}

- (NSString *)timeStringWith:(NSInteger)seconds {
    NSInteger hour = 0;
    NSInteger minute = 0;
    NSInteger second = 0;
    
    NSString *time;
    if (seconds >= 3600) {
        hour = seconds / 3600;
        minute = (seconds % 3600) / 600;
        second = seconds % 60;
        time = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hour,minute,second];
    } else {
        minute = seconds / 60;
        second = seconds % 60;
        time = [NSString stringWithFormat:@"%02ld:%02ld",minute,second];
    }
    
    return time;
}

- (void)setMaxDuration:(NSInteger)totalSecond {
    _totalTime = totalSecond;
    _playProgress.maximumValue = totalSecond;
    
    self.totalTimeLabel.text = [self timeStringWith:totalSecond];
}

// 已缓冲进度
- (NSTimeInterval)availableDurationRanges {
    NSArray *loadedTimeRanges = [_playerItem loadedTimeRanges]; // 获取item的缓冲数组
    // discussion Returns an NSArray of NSValues containing CMTimeRanges
    
    // CMTimeRange 结构体 start duration 表示起始位置 和 持续时间
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue]; // 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds; // 计算总缓冲时间 = start + duration
    return result;
}

#pragma mark
- (void)backClick {
    if (self.isLandscape) {
        [self rotationPlayer];
        
    } else {
        
        [self.player pause];
        if (self.BackBlock) {
            self.BackBlock();
        }
    }
}

- (void)hideStatusBar {
    if (self.lockButton.selected) {
        self.lockButton.hidden = !self.lockButton.hidden;
    } else {
        self.statusBarHidden = !self.statusBarHidden;
        
        self.topView.hidden = self.statusBarHidden;
        self.bottomView.hidden = self.statusBarHidden;
        self.lockButton.hidden = self.statusBarHidden;
        if (!self.isLandscape) {
            self.lockButton.hidden = YES;
        }
        
        [self prefersStatusBarHidden];
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)videoPaly {
    if (self.player.rate) {
        [self.player pause];
        _playButton.selected = !_playButton.selected;
    } else {
        if (_player.status == AVPlayerStatusReadyToPlay) {
            [self.player play];
            _playButton.selected = !_playButton.selected;
        }
    }
}

- (void)rotationPlayer {
    self.isAutorotate = YES;
    
    self.isLandscape = !self.isLandscape;
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    if (self.isLandscape) {//要转成横屏
        orientation = UIInterfaceOrientationLandscapeLeft;
    }
    
    NSNumber *orientationTarget = [NSNumber numberWithInt:orientation];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
}

- (void)playerDidPlayToEnd {
    [self.player seekToTime:CMTimeMake(0, 1)];
    self.playButton.selected = NO;
}

- (void)lockScreen:(UIButton *)button {
    
    [self tapOnPLayer:nil];
    button.selected = !button.selected;
    if (!button.selected) {
        [self tapOnPLayer:nil];
    }
    button.hidden = NO;
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.isAutorotate = button.selected;
}

#pragma mark - 旋转
- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    
    if (newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        //横屏
        self.isLandscape = YES;
        self.statusBarView.hidden = YES;
        self.lockButton.hidden = self.statusBarHidden;
        
        self.playerLayer.frame = CGRectMake(0, 0, Screen_W, Screen_H);
        
        self.topView.frame = CGRectMake(0, 20, Screen_W, 44);
        self.bottomView.frame = CGRectMake(0, Screen_H - 44, Screen_W, 44);
        
    } else {
        //竖屏
        self.isLandscape = NO;
        self.statusBarView.hidden = NO;
        self.lockButton.hidden = YES;
        
        self.playerLayer.frame = CGRectMake(0, 20, Screen_W, Screen_W * PlayerHeightScale);
        
        CGFloat playerH = Screen_W * PlayerHeightScale + 20;
        
        self.topView.frame = CGRectMake(0, 20, Screen_W, 44);
        self.bottomView.frame = CGRectMake(0, playerH - 44, Screen_W, 44);
        
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        app.isAutorotate = YES;
    }
    
    self.loadingProgress.bounds = CGRectMake(0, 0, Screen_W * self.ProgressScale, 10);
    self.loadingProgress.center = CGPointMake(Screen_W * 0.5, 22);
    
    self.playProgress.bounds = CGRectMake(0, 0, Screen_W * self.ProgressScale, 10);
    self.playProgress.center = CGPointMake(Screen_W * 0.5, 22);
    
    self.totalTimeLabel.frame = CGRectMake(CGRectGetMaxX(_loadingProgress.frame) + 10, 0, 60, 44);
    self.currentTimeLabel.frame = CGRectMake(CGRectGetMinX(_loadingProgress.frame) - 70, 0, 60, 44);
    
    self.rotationButton.frame = CGRectMake(Screen_W - 40, 0, 40, 40);
    
    self.isAutorotate = NO;
}

//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
//    NSLog(@"viewWillTransitionToSize");
//    NSLog(@"%f",Screen_W);
//}

#pragma mark - UISlider事件
- (void)playerSeekTo:(UISlider *)slider {
    [self.playerItem seekToTime:CMTimeMakeWithSeconds(slider.value, 1.0)];
    self.currentTimeLabel.text = [self timeStringWith:slider.value];
}

- (void)sliderTouchDown:(UISlider *)slider {
    self.isSliding = YES;
}

- (void)sliderTouchUpInside:(UISlider *)slider {
    self.isSliding = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideStatusBarIfNeed) object:nil];
    [self performSelector:@selector(hideStatusBarIfNeed) withObject:nil afterDelay:5.0];
}

#pragma mark - 手势
- (void)tapOnPLayer:(UITapGestureRecognizer *)tap {
    [self hideStatusBar];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideStatusBarIfNeed) object:nil];
    [self performSelector:@selector(hideStatusBarIfNeed) withObject:nil afterDelay:5.0];
}

- (void)doubleTapOnPLayer:(UITapGestureRecognizer *)tap {
    [self videoPaly];
}

- (void)panOnPlayer:(UIPanGestureRecognizer *)pan {
//    UIGestureRecognizerState state = gestureRecognizer.state;
//    CGPoint point = [gestureRecognizer locationInView:self.window];
//    
//    if (state == UIGestureRecognizerStateChanged) {
//        CGFloat change_X = point.x - self.lastPanPoint.x;
//        CGFloat change_Y = point.y - self.lastPanPoint.y;
//        
//        CGPoint center = self.player.playerView.center;
//        
//        CGFloat Center_X = center.x + change_X;
//        CGFloat Center_Y = center.y + change_Y;
//        CGFloat scale = PlayerViewScale * 0.5;
//        
//        if (Center_X < Screen_W * scale) {
//            Center_X = Screen_W * scale;
//        } else if (Center_X > Screen_W * (1 - scale)) {
//            Center_X = Screen_W * (1 - scale);
//        }
//        
//        if (Center_Y < Screen_H * scale) {
//            Center_Y = Screen_H * scale;
//        } else if (Center_Y > Screen_H * (1 - scale)) {
//            Center_Y = Screen_H * (1 - scale);
//        }
//        
//        self.player.playerView.center = CGPointMake(Center_X, Center_Y);
//    }
//    
//    self.lastPanPoint = point;
}

- (void)swipOnPlayer:(UISwipeGestureRecognizer *)swipe {
    CMTime currentTime = self.playerItem.currentTime;
    int64_t currentSeconds = currentTime.value / currentTime.timescale;
    
    int32_t timescale = self.playerItem.duration.timescale;
    [self.playerItem seekToTime:CMTimeMake((currentSeconds + 5) * timescale, timescale)];
    
    self.playProgress.value = currentSeconds + 5;
}

#pragma mark
- (void)hideStatusBarIfNeed {
    if ((!self.statusBarHidden || !self.lockButton.hidden) && !self.isSliding) {
        [self hideStatusBar];
    }
}

#pragma mark
- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        
        NSURL *url;
        if ([self.urlString hasPrefix:@"http"]) {
            url = [NSURL URLWithString:self.urlString];
        } else {
            url = [NSURL fileURLWithPath:self.urlString];
        }
        
        _playerItem = [AVPlayerItem playerItemWithURL:url];
        _player = [AVPlayer playerWithPlayerItem:_playerItem];
        
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.frame = CGRectMake(0, 20, Screen_W, Screen_W * PlayerHeightScale);
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _playerLayer;
}

- (CGFloat)ProgressScale {
    if (self.isLandscape) {
        return 0.6;
    }
    return 0.5;
}

//- (NSTimer *)timer {
//    if (!_timer) {
//        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * timer) {
//            CMTime totalTime = self.playerItem.duration;
//            CMTime currentTime = self.playerItem.currentTime;
//            
//            int64_t totalSeconds = totalTime.value / totalTime.timescale;
//            int64_t currentSeconds = currentTime.value / currentTime.timescale;
//            
//            self.progressView.progress = currentSeconds /1.0 / totalSeconds;
//        }];
//        [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
//    }
//    return _timer;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
