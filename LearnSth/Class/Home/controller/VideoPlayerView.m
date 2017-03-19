//
//  VideoPlayerView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/18.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "VideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@interface VideoPlayerView (){
    id playerTimeObserver;
}

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *rotationButton;

@property (nonatomic, strong) UIProgressView *loadingProgress;//加载进度
@property (nonatomic, strong) UISlider *playProgress;//播放进度

@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;

@property (nonatomic, strong) UIButton *lockButton;

@property (nonatomic, assign) BOOL isScreenLocked;//是否锁屏
@property (nonatomic, assign) BOOL isSliding;//是否正在划动进度条
@property (nonatomic, assign) BOOL isTopViewHidden;//是否显示顶部、底部
//@property (nonatomic, assign) BOOL isLandscape;//是否横屏

@property (nonatomic, assign) double totalTime;

@end

const CGFloat HeightScale = 0.5625;//竖屏时，player高度
const CGFloat BottomH = 40;

@implementation VideoPlayerView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectZero]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.frame = CGRectMake(0, 20, Screen_W, Screen_W * HeightScale);
    self.clipsToBounds = YES;
    
    self.isTopViewHidden = NO;
}

-(void)setUrlString:(NSString *)urlString {
    if (urlString && !_urlString) {
        _urlString = urlString;
        [self.layer addSublayer:self.playerLayer];
        
        [self initTopView];
        [self initBottonView];
        
        [self addPlayerObserver];
        [self addGesture];
    }
}

#pragma mark
- (void)initTopView {
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_W, BottomH)];
    topView.backgroundColor = [UIColor clearColor];
    [self addSubview:topView];
    _topView = topView;
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BottomH - 5, BottomH)];
    [backButton setImage:[UIImage imageNamed:@"backButtonImage"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backButton];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(BottomH - 5, 0, 200, BottomH)];
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.textColor = [UIColor whiteColor];
    [topView addSubview:nameLabel];
    nameLabel.text = self.name;
}

- (void)initBottonView {
    UIButton *lockButton = [[UIButton alloc] init];
    lockButton.frame = CGRectMake(BottomH, (Screen_W - BottomH) * 0.5, BottomH, BottomH);
    //    [lockButton setImage:[UIImage imageNamed:@"playerLockScreen"] forState:UIControlStateNormal];
    lockButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [lockButton setTitle:@"锁屏" forState:UIControlStateNormal];
    [lockButton setTitle:@"解锁" forState:UIControlStateSelected];
    [lockButton addTarget:self action:@selector(lockScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:lockButton];
    _lockButton = lockButton;
    _lockButton.hidden = YES;
    
    //－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
    CGFloat playerH = Screen_W * HeightScale;
    
    UIView *bottomView = [[UIView alloc] init];
    bottomView.frame = CGRectMake(0, playerH - BottomH, Screen_W, BottomH);
    bottomView.backgroundColor = [UIColor clearColor];
    [self addSubview:bottomView];
    _bottomView = bottomView;
    
    CGFloat height = CGRectGetHeight(_bottomView.frame);
    
    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, height, height)];
    [playButton setImage:[UIImage imageNamed:@"playerStart"] forState:UIControlStateNormal];
    [playButton setImage:[UIImage imageNamed:@"playerPause"] forState:UIControlStateSelected];
    [playButton addTarget:self action:@selector(videoPaly) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:playButton];
    _playButton = playButton;
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, Screen_W * 0.5, 20)];
    progressView.progress = 0.0;
    progressView.center = CGPointMake(Screen_W * 0.5, height * 0.5);
    progressView.trackTintColor = [UIColor whiteColor];
    progressView.progressTintColor = KBaseBlueColor;
    [bottomView addSubview:progressView];
    _loadingProgress = progressView;
    
    UISlider *slider = [[UISlider alloc] initWithFrame:progressView.frame];
    slider.maximumTrackTintColor = [UIColor clearColor];
    slider.minimumTrackTintColor = [UIColor clearColor];
    [slider setThumbImage:[UIImage imageNamed:@"playerSliderDot"] forState:UIControlStateNormal];
    //    [slider addTarget:self action:@selector(playerSeekTo:) forControlEvents:UIControlEventValueChanged];
    //    [slider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    //    [slider addTarget:self action:@selector(sliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:slider];
    _playProgress = slider;
    
    UILabel *currentSecondsLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(progressView.frame) - 70, 0, 60, height)];
    currentSecondsLabel.font = [UIFont systemFontOfSize:12];
    currentSecondsLabel.textColor = [UIColor whiteColor];
    currentSecondsLabel.textAlignment = NSTextAlignmentRight;
    [bottomView addSubview:currentSecondsLabel];
    _currentTimeLabel = currentSecondsLabel;
    
    UILabel *totalSecondsLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(progressView.frame) + 10, 0, 60, height)];
    totalSecondsLabel.font = [UIFont systemFontOfSize:12];
    totalSecondsLabel.textColor = [UIColor whiteColor];
    [bottomView addSubview:totalSecondsLabel];
    _totalTimeLabel = totalSecondsLabel;
    
    UIButton *rotationButton = [[UIButton alloc] initWithFrame:CGRectMake(Screen_W - height, 0, height, height)];
    [rotationButton setImage:[UIImage imageNamed:@"playerFullScreen"] forState:UIControlStateNormal];
    [rotationButton addTarget:self action:@selector(fullScreen) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:rotationButton];
    _rotationButton = rotationButton;
}

- (void)addGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPlayer:)];
    [self addGestureRecognizer:tap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapOnPlayer:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    [tap requireGestureRecognizerToFail:doubleTap];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipOnPlayer:)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipe];
    
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

#pragma mark
- (void)pausePlayer {
    [self.player pause];
}

- (void)playerDidPlayToEnd {
    [self.player seekToTime:CMTimeMake(0, 1)];
    self.playButton.selected = NO;
}

#pragma mark - kvo:播放状态，加载进度
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    AVPlayerItem *item = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if (status == AVPlayerStatusReadyToPlay) {
            CMTime duration = item.duration;
            [self setMaxDuration:CMTimeGetSeconds(duration)];
            [self videoPaly];
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTopViewIfNeed) object:nil];
            [self performSelector:@selector(hideTopViewIfNeed) withObject:nil afterDelay:5.0];
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
    
    // CMTimeRange 结构体 start duration 表示起始位置 和 持续时间
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue]; // 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds; // 计算总缓冲时间 = start + duration
    return result;
}

#pragma mark - 按钮方法
- (void)backButtonClick {
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

- (void)fullScreen {
    if (self.FullScreenBlock) {
        self.FullScreenBlock();
    }
}

- (void)lockScreen:(UIButton *)button {
    button.selected = !button.selected;
    self.isScreenLocked = button.selected;
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.isAutorotate = !button.selected;
    
    [self showTopView];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTopViewIfNeed) object:nil];
    [self performSelector:@selector(hideTopViewIfNeed) withObject:nil afterDelay:5.0];
}

#pragma mark - 手势
- (void)tapOnPlayer:(UITapGestureRecognizer *)tap {
    if (self.isScreenLocked) {
        [self showLockButton];
        if (self.TapGestureBlock) {
            self.TapGestureBlock();
        }
        
    } else {
        [self showTopView];
        [self showLockButton];
        if (self.TapGestureBlock) {
            self.TapGestureBlock();
        }
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTopViewIfNeed) object:nil];
    [self performSelector:@selector(hideTopViewIfNeed) withObject:nil afterDelay:5.0];
}

- (void)doubleTapOnPlayer:(UITapGestureRecognizer *)tap {
    [self videoPaly];
}

- (void)swipOnPlayer:(UISwipeGestureRecognizer *)swipe {
    double currentTime = CMTimeGetSeconds(self.playerItem.currentTime);
    
    [self.playerItem seekToTime:CMTimeMake(currentTime + 10, 1)];
    self.playProgress.value = currentTime + 10;
}

#pragma mark -
- (void)showTopView {
    CGRect topViewRect = self.topView.frame;
    CGRect bottomViewRect = self.bottomView.frame;
    
    if (self.isTopViewHidden) {
        topViewRect.origin.y += 20 - CGRectGetMinY(self.frame) + BottomH;
        bottomViewRect.origin.y -= BottomH;
        
    } else {
        topViewRect.origin.y -= 20 - CGRectGetMinY(self.frame) + BottomH;
        bottomViewRect.origin.y += BottomH;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.topView.frame = topViewRect;
        self.bottomView.frame = bottomViewRect;
        
    } completion:^(BOOL finished) {
        self.isTopViewHidden = !self.isTopViewHidden;
    }];
}

- (void)showLockButton {
    if (self.lockButton.hidden == YES) {
        CGRect lockButtonRect = self.lockButton.frame;
        lockButtonRect.origin.x =  -BottomH;
        self.lockButton.frame = lockButtonRect;
        
    } else {
        CGRect lockButtonRect = self.lockButton.frame;
        lockButtonRect.origin.x = (lockButtonRect.origin.x > 0) ? -BottomH : BottomH;
        [UIView animateWithDuration:0.3 animations:^{
            self.lockButton.frame = lockButtonRect;
        }];
    }
}

- (void)hideTopViewIfNeed {
    if (!self.isTopViewHidden) {
        
        [self showTopView];
        [self showLockButton];
        
        if (self.TapGestureBlock) {
            self.TapGestureBlock();
        }
    } else if (self.isScreenLocked == YES) {
        [self showLockButton];
        
        if (self.TapGestureBlock) {
            self.TapGestureBlock();
        }
    }
}

#pragma mark - (屏幕旋转)
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    if (previousTraitCollection.verticalSizeClass != UIUserInterfaceSizeClassRegular) {
        //竖屏
        self.frame = CGRectMake(0, 20, Screen_W, Screen_W * HeightScale);
        self.playerLayer.frame = CGRectMake(0, 0, Screen_W, Screen_W * HeightScale);
        
        if (!self.isTopViewHidden) {
            self.topView.frame = CGRectMake(0, 0, Screen_W, BottomH);
            self.bottomView.frame = CGRectMake(0, Screen_W * HeightScale - BottomH, Screen_W, BottomH);
        } else {
            self.topView.frame = CGRectMake(0, -BottomH, Screen_W, BottomH);
            self.bottomView.frame = CGRectMake(0, Screen_W * HeightScale, Screen_W, BottomH);
        }
        
        self.lockButton.hidden = YES;
        CGRect lockButtonRect = self.lockButton.frame;
        lockButtonRect.origin.x = -BottomH;
        self.lockButton.frame = lockButtonRect;
    } else {
        //横屏
        self.frame = CGRectMake(0, 0, Screen_W, Screen_H);
        self.playerLayer.frame = CGRectMake(0, 0, Screen_W, Screen_H);
        
        self.lockButton.hidden = NO;
        if (!self.isTopViewHidden) {
            CGRect lockButtonRect = self.lockButton.frame;
            lockButtonRect.origin.x = BottomH;
            [UIView animateWithDuration:0.3 animations:^{
                self.lockButton.frame = lockButtonRect;
                
                self.topView.frame = CGRectMake(0, 20, Screen_W, BottomH);
                self.bottomView.frame = CGRectMake(0, Screen_H - BottomH, Screen_W, BottomH);
            }];
        } else {
            self.topView.frame = CGRectMake(0, - BottomH, Screen_W, BottomH);
            self.bottomView.frame = CGRectMake(0, Screen_H, Screen_W, BottomH);
        }
    }
    
    self.loadingProgress.bounds = CGRectMake(0, 0, Screen_W * 0.5, 20);
    self.loadingProgress.center = CGPointMake(Screen_W * 0.5, BottomH * 0.5);
    
    self.playProgress.bounds = CGRectMake(0, 0, Screen_W * 0.5, 20);
    self.playProgress.center = CGPointMake(Screen_W * 0.5, BottomH * 0.5);
    
    self.totalTimeLabel.frame = CGRectMake(CGRectGetMaxX(_loadingProgress.frame) + 10, 0, 60, BottomH);
    self.currentTimeLabel.frame = CGRectMake(CGRectGetMinX(_loadingProgress.frame) - 70, 0, 60, BottomH);
    
    self.rotationButton.frame = CGRectMake(Screen_W - BottomH, 0, BottomH, BottomH);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTopViewIfNeed) object:nil];
    [self performSelector:@selector(hideTopViewIfNeed) withObject:nil afterDelay:5.0];
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
        _playerLayer.frame = CGRectMake(0, 0, Screen_W, Screen_W * 0.5625);
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _playerLayer;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_player removeTimeObserver:playerTimeObserver];
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

@end
