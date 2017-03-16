//
//  VideoPlayerController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/13.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "VideoPlayerController.h"
#import <AVFoundation/AVFoundation.h>

@interface VideoPlayerController () {
    id playerTimeObserver;
    
    CGFloat viewHeight;
    CGFloat viewWidth;
}

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL isLandscape;//是否横屏

//@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIProgressView *loadingProgress;//加载进度
@property (nonatomic, strong) UISlider *playProgress;//播放进度
@property (nonatomic, assign) BOOL isSliding;

@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;

@property (nonatomic, assign) double totalTime;

//@property (nonatomic, assign) CGPoint lastPoint;

@end

@implementation VideoPlayerController
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (self.isLandscape) {
        return UIInterfaceOrientationLandscapeLeft;
    }
    return UIInterfaceOrientationPortrait;
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
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.isLandscape = NO;
    viewWidth = Screen_W;
    viewHeight = Screen_H;
    
    if (self.isLandscape) {
        viewHeight = Screen_W;
        viewWidth = Screen_H;
    }
    
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_player removeTimeObserver:playerTimeObserver];
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

- (void)initSubView {
    if (!self.isLandscape) {
        UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 20)];
        blackView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:blackView];
    }
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, viewWidth, 44)];
    topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topView];
    _topView = topView;
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setImage:[UIImage imageNamed:@"backButtonImage"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backButton];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight - 44, viewWidth, 44)];
    bottomView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bottomView];
    _bottomView = bottomView;
    
    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 44, 44)];
    [playButton setImage:[UIImage imageNamed:@"playerPause"] forState:UIControlStateSelected];
    [playButton setImage:[UIImage imageNamed:@"playerStart"] forState:UIControlStateNormal];
    playButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [playButton addTarget:self action:@selector(videoPaly) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:playButton];
    _playButton = playButton;
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, viewWidth * 0.6, 10)];
    progressView.progress = 0.0;
    progressView.center = CGPointMake(viewWidth * 0.5, 44 * 0.5);
    progressView.trackTintColor = [UIColor whiteColor];
    progressView.progressTintColor = KBaseBlueColor;
    [bottomView addSubview:progressView];
    _loadingProgress = progressView;
    
    UISlider *slider = [[UISlider alloc] initWithFrame:progressView.frame];
    slider.maximumTrackTintColor = [UIColor clearColor];
    slider.minimumTrackTintColor = [UIColor clearColor];
    [slider setThumbImage:[UIImage imageNamed:@"whiteDot"] forState:UIControlStateNormal];
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

#pragma mark kvo
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
- (void)hideStatusBar {
    self.statusBarHidden = !self.statusBarHidden;
    
    self.topView.hidden = self.statusBarHidden;
    self.bottomView.hidden = self.statusBarHidden;
    
    [self prefersStatusBarHidden];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)playerDidPlayToEnd {
    [self.player seekToTime:CMTimeMake(0, 1)];
    self.playButton.selected = NO;
}

- (void)back {
    [self.player pause];
    if (self.BackBlock) {
        self.BackBlock();
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

#pragma mark
- (void)playerSeekTo:(UISlider *)slider {
    [self.playerItem seekToTime:CMTimeMakeWithSeconds(slider.value, 1.0)];
    self.currentTimeLabel.text = [self timeStringWith:slider.value];
}

- (void)sliderTouchDown:(UISlider *)slider {
    self.isSliding = YES;
}

- (void)sliderTouchUpInside:(UISlider *)slider {
    self.isSliding = NO;
}

#pragma mark
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

- (void)hideStatusBarIfNeed {
    if (!self.statusBarHidden) {
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
        if (self.isLandscape) {
            _playerLayer.frame = CGRectMake(0, 0, Screen_H, Screen_W);
        } else {
            _playerLayer.frame = CGRectMake(0, 20, Screen_W, Screen_W * 0.5);
        }
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _playerLayer;
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
