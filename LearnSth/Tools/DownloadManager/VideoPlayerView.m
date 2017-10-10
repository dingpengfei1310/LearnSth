//
//  VideoPlayerView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/18.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "VideoPlayerView.h"

#import "AppDelegate.h"
#import "BaseConfigure.h"
#import "UIView+Tool.h"
#import <AVFoundation/AVFoundation.h>
#import <NSObject+MemoryLeak.h>

@interface VideoPlayerView () <UIGestureRecognizerDelegate>{
    id playerTimeObserver;
    
    CGFloat viewW;
    CGFloat viewH;
}

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *rotationButton;

@property (nonatomic, strong) UIProgressView *loadingView;//加载进度
@property (nonatomic, strong) UISlider *playSlider;//播放进度

@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;

@property (nonatomic, strong) UIButton *lockButton;

@property (nonatomic, assign) BOOL isScreenLocked;//是否锁屏
@property (nonatomic, assign) BOOL isTopViewHidden;//是否显示顶部、底部
@property (nonatomic, assign) BOOL isSliding;//是否正在拖动进度条（或者滑动快进）

@property (nonatomic, assign) double totalTime;
@property (nonatomic, assign) NSInteger timeScale;

@property (nonatomic, assign) UIInterfaceOrientation lastOrientation;//上次的方向，旋转用
@property (nonatomic, assign) CGPoint lastPoint;

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
    viewW = [UIScreen mainScreen].bounds.size.width;
    viewH = [UIScreen mainScreen].bounds.size.height;
    
    self.backgroundColor = [UIColor blackColor];
    self.clipsToBounds = YES;
}

-(void)setFileUrl:(NSString *)fileUrl {
    if (fileUrl && !_fileUrl) {
        _fileUrl = fileUrl;
        
        [self.layer addSublayer:self.playerLayer];
        
        [self initTopView];
        [self initBottonView];
        
        [self addPlayerObserver];
        [self addGesture];
        
        [self showHud];
    }
}

#pragma mark
- (void)showHud {
    [self hideHUD];
    [self loading];
    
    [self bringSubviewToFront:_topView];
    [self bringSubviewToFront:_bottomView];
}

#pragma mark
- (void)initTopView {
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewW, BottomH)];
    topView.backgroundColor = [UIColor clearColor];
    [self addSubview:topView];
    _topView = topView;
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, BottomH)];
    [backButton setImage:[UIImage imageNamed:@"backButton"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backButton];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, viewW - BottomH, BottomH)];
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.textColor = [UIColor whiteColor];
    [topView addSubview:nameLabel];
    nameLabel.text = self.fileName;
    
//    UIButton *screenCaptureButton = [[UIButton alloc] initWithFrame:CGRectMake(viewH - BottomH, 0, BottomH, BottomH)];
//    [screenCaptureButton setTitle:@"截屏" forState:UIControlStateNormal];
//    screenCaptureButton.titleLabel.font = [UIFont systemFontOfSize:13];
//    [screenCaptureButton addTarget:self action:@selector(screenCapture) forControlEvents:UIControlEventTouchUpInside];
//    [topView addSubview:screenCaptureButton];
}

- (void)initBottonView {
    UIButton *lockButton = [[UIButton alloc] init];
    lockButton.frame = CGRectMake(-BottomH * 0.5, (viewW - BottomH * 1.2) * 0.5, BottomH * 1.2, BottomH * 1.2);
    lockButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [lockButton setTitle:@"锁屏" forState:UIControlStateNormal];
    [lockButton setTitle:@"解锁" forState:UIControlStateSelected];
    lockButton.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    lockButton.layer.cornerRadius = BottomH * 0.6;
    lockButton.layer.masksToBounds = YES;
    [lockButton addTarget:self action:@selector(lockScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:lockButton];
    _lockButton = lockButton;
    _lockButton.hidden = YES;
    
    //－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
    CGFloat playerH = viewW * HeightScale;
    
    UIView *bottomView = [[UIView alloc] init];
    bottomView.frame = CGRectMake(0, playerH - BottomH, viewW, BottomH);
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
    
    _loadingView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, viewW * 0.5, 20)];
    _loadingView.center = CGPointMake(viewW * 0.5, height * 0.5);
    _loadingView.trackTintColor = [UIColor whiteColor];
    _loadingView.progressTintColor = [UIColor lightGrayColor];
    [bottomView addSubview:_loadingView];
    
    UISlider *playSlider = [[UISlider alloc] initWithFrame:_loadingView.frame];
    playSlider.continuous = NO;
    playSlider.minimumValue = 0.0;
    playSlider.maximumTrackTintColor = [UIColor clearColor];
    playSlider.minimumTrackTintColor = [UIColor redColor];
    [playSlider setThumbImage:[UIImage imageNamed:@"playerSliderDot"] forState:UIControlStateNormal];
    [playSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [playSlider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    
    [playSlider addTarget:self action:@selector(sliderTouchDrag:) forControlEvents:UIControlEventTouchDragInside];
    [playSlider addTarget:self action:@selector(sliderTouchDrag:) forControlEvents:UIControlEventTouchDragOutside];
    
    [bottomView addSubview:playSlider];
    _playSlider = playSlider;
    
    UILabel *currentTime = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(playSlider.frame) - 70, 0, 60, height)];
    currentTime.font = [UIFont systemFontOfSize:11];
    currentTime.textColor = [UIColor whiteColor];
    currentTime.textAlignment = NSTextAlignmentCenter;
    currentTime.text = @"00:00";
    [bottomView addSubview:currentTime];
    _currentTimeLabel = currentTime;
    
    UILabel *totalTime = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(playSlider.frame) + 10, 0, 60, height)];
    totalTime.font = [UIFont systemFontOfSize:11];
    totalTime.textColor = [UIColor whiteColor];
    totalTime.textAlignment = NSTextAlignmentCenter;
    [bottomView addSubview:totalTime];
    _totalTimeLabel = totalTime;
    
    UIButton *rotationButton = [[UIButton alloc] initWithFrame:CGRectMake(viewW - height, 0, height, height)];
    [rotationButton setImage:[UIImage imageNamed:@"playerFullScreen"] forState:UIControlStateNormal];
    [rotationButton addTarget:self action:@selector(fullScreen) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:rotationButton];
    _rotationButton = rotationButton;
}

- (void)addGesture {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.delegate = self;
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.delegate = self;
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
//    UISwipeGestureRecognizer *forward = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipOnPlayer:)];
//    forward.delegate = self;
//    forward.direction = UISwipeGestureRecognizerDirectionRight;
//    [self addGestureRecognizer:forward];
//    
//    UISwipeGestureRecognizer *backWord = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipOnPlayer:)];
//    backWord.delegate = self;
//    backWord.direction = UISwipeGestureRecognizerDirectionLeft;
//    [self addGestureRecognizer:backWord];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOnPlayer:)];
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
}

- (void)addPlayerObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidPlayToEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    
    __weak typeof(self) wSelf = self;
    playerTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        if (!wSelf.isSliding) {
            wSelf.playSlider.value = CMTimeGetSeconds(time);
            wSelf.currentTimeLabel.text = [wSelf stringWithTime:CMTimeGetSeconds(time)];
        }
    }];
}

#pragma mark
- (void)pausePlayer {
    self.player.rate = 0;
    [self.player pause];
}

- (void)playerDidPlayToEnd {
    [self.playerItem seekToTime:CMTimeMake(0, 1)];
    self.playButton.selected = NO;
}

- (void)seekToPlayerTime:(CMTime)time {
    [self.playerItem seekToTime:time completionHandler:^(BOOL finished) {
        self.isSliding = NO;
        
        if (!self.playerItem.isPlaybackLikelyToKeepUp) {
            [self showHud];
        }
    }];
}

- (void)screenCapture {
    AVAssetImageGenerator *genator = [[AVAssetImageGenerator alloc] initWithAsset:self.playerItem.asset];
    CGImageRef imageRef = [genator copyCGImageAtTime:self.playerItem.currentTime actualTime:NULL error:NULL];
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    CGImageRelease(imageRef);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
}

#pragma mark - kvo:播放状态，加载进度
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    AVPlayerItem *item = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [[change objectForKey:@"new"] intValue];
        if (status == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"status");
            [self setMaxDuration:item.duration];
//            [self videoPaly];
            
            [self delayExecute];
        } else if (status == AVPlayerItemStatusFailed) {
            [self hideHUD];
            [self backButtonClick];
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        double timeInterval = [self availableDurationRanges];// 缓冲时间
        self.loadingView.progress = (self.totalTime == 0.0) ? 0.0 : timeInterval / _totalTime;
        
        if (timeInterval > CMTimeGetSeconds(self.playerItem.currentTime)) {
            [self hideHUD];
        }
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) { //监听播放器在缓冲数据的状态
        if (_playerItem.isPlaybackBufferEmpty) {
            [self showHud];
        }
    }
}

- (void)setMaxDuration:(CMTime)duration {
    _timeScale = duration.timescale;
    _totalTime = CMTimeGetSeconds(duration);
    
    self.playSlider.maximumValue = _totalTime;
    self.totalTimeLabel.text = [self stringWithTime:_totalTime];
}

// 已缓冲进度
- (double)availableDurationRanges {
    NSArray *loadedTimeRanges = [_playerItem loadedTimeRanges]; // 获取item的缓冲数组
    // CMTimeRange 结构体 start duration 表示起始位置 和 持续时间
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue]; // 获取缓冲区域
    double startSeconds = CMTimeGetSeconds(timeRange.start);
    double durationSeconds = CMTimeGetSeconds(timeRange.duration);
    double result = startSeconds + durationSeconds; // 计算总缓冲时间 = start + duration
    
    return result;
}

- (NSString *)stringWithTime:(NSInteger)seconds {
//    NSInteger hour = 0;
    NSInteger minute = 0;
    NSInteger second = 0;
    
    NSString *time;
    if (seconds >= 3600) {
//        hour = seconds / 3600;
//        minute = (seconds % 3600) / 600;
//        second = seconds % 60;
//        time = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hour,minute,second];
        
        minute = seconds / 600;
        second = seconds % 60;
        time = [NSString stringWithFormat:@"%ld:%02ld",minute,second];
    } else {
        minute = seconds / 60;
        second = seconds % 60;
        time = [NSString stringWithFormat:@"%02ld:%02ld",minute,second];
    }
    
    return time;
}

#pragma mark - 按钮方法
- (void)backButtonClick {
    self.BackBlock ? self.BackBlock() : 0;
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
    self.FullScreenBlock ? self.FullScreenBlock() : 0;
}

- (void)lockScreen:(UIButton *)button {
    button.selected = !button.selected;
    self.isScreenLocked = button.selected;
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.isAutorotate = !button.selected;
    
    [self showTopView];
    [self delayExecute];
}

#pragma mark - 手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UISlider class]]) {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.isSliding) {
        return NO;
    }
    
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return YES;
    }
    
    if (self.lockButton.selected) {
        return NO;
    }
    return YES;
}

- (void)singleTap:(UITapGestureRecognizer *)singleTap {
    if (!self.isScreenLocked) {
        [self showTopView];
    }
    
    [self showLockButton];
    [self delayExecute];
    self.TapGestureBlock ? self.TapGestureBlock() : 0;
}

- (void)doubleTap:(UITapGestureRecognizer *)doubleTap {
    [self videoPaly];
}

- (void)panOnPlayer:(UIPanGestureRecognizer *)panGesture {
    UIGestureRecognizerState state = panGesture.state;
    CGPoint point = [panGesture locationInView:self];
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
        {
            self.lastPoint = point;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGFloat distanceX = point.x - self.lastPoint.x;
            CGFloat distanceY = point.y - self.lastPoint.y;
            if (fabs(distanceX) <= fabs(distanceY)) {
                break;
            }
            
            self.isSliding = YES;
            CGFloat value = distanceX / self.frame.size.width * _totalTime;
            
            self.playSlider.value = MIN(self.playSlider.value + value, _totalTime);
            self.lastPoint = point;
            
            NSString *text = [NSString stringWithFormat:@"%@ / %@",[self stringWithTime:self.playSlider.value],[self stringWithTime:_totalTime]];
            [self showMessage:text];
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [self hideHUD];
            if (self.isSliding) {
                [self sliderValueChanged:self.playSlider];
            }
            
            break;
        }
        default:
        {
            break;
        }
            
    }
}

- (void)swipOnPlayer:(UISwipeGestureRecognizer *)swipe {
    //快进、快退15秒
    NSInteger seconds = 15;
    double currentTime = CMTimeGetSeconds(self.playerItem.currentTime);
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        [self seekToPlayerTime:CMTimeMake((currentTime + seconds) * _timeScale, _timeScale * 1.0)];
        self.playSlider.value = currentTime + seconds;
        
    } else if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self seekToPlayerTime:CMTimeMake((currentTime - seconds) * _timeScale, _timeScale * 1.0)];
        self.playSlider.value = currentTime - seconds;
    }
}

#pragma mark - UISlider事件
- (void)sliderTouchDown:(UISlider *)slider {
    self.isSliding = YES;
}

- (void)sliderTouchDrag:(UISlider *)slider {
    NSString *text = [NSString stringWithFormat:@"%@ / %@",[self stringWithTime:self.playSlider.value],[self stringWithTime:_totalTime]];
    [self showMessage:text];
}

- (void)sliderValueChanged:(UISlider *)slider {
    [self hideHUD];
    
    self.currentTimeLabel.text = [self stringWithTime:slider.value];
    [self seekToPlayerTime:CMTimeMakeWithSeconds(slider.value, _timeScale * 1.0)];
    
    [self delayExecute];
}

#pragma mark -
- (void)showTopView {
    CGRect topViewRect = self.topView.frame;
    CGRect bottomViewRect = self.bottomView.frame;
    
    if (self.isTopViewHidden) {
        topViewRect.origin.y = 20;
        bottomViewRect.origin.y -= BottomH;
        
    } else {
        topViewRect.origin.y = -BottomH;
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
    if (self.lockButton.hidden != YES) {
        CGRect lockButtonRect = self.lockButton.frame;
        lockButtonRect.origin.x = (lockButtonRect.origin.x > 0) ? -BottomH * 1.2 : BottomH * 0.5;
        [UIView animateWithDuration:0.3 animations:^{
            self.lockButton.frame = lockButtonRect;
        }];
    }
}

- (void)hideTopViewIfNeed {
    if (self.isSliding) {
        return;
    }
    
    if (!self.isTopViewHidden) {
        [self showTopView];
        [self showLockButton];
        
        self.TapGestureBlock ? self.TapGestureBlock() : 0;
        
    } else if (self.lockButton.frame.origin.x > 0) {
        [self showLockButton];
        
        self.TapGestureBlock ? self.TapGestureBlock() : 0;
    }
}

//5秒后自动隐藏topView
- (void)delayExecute {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTopViewIfNeed) object:nil];
    [self performSelector:@selector(hideTopViewIfNeed) withObject:nil afterDelay:5.0];
}

#pragma mark - (屏幕旋转)
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    NSTimeInterval duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    
    CGFloat spaceW = 0;
    if (previousTraitCollection.verticalSizeClass != UIUserInterfaceSizeClassRegular) {
        //竖屏
        self.frame = CGRectMake(0, StatusBarH - 20, viewW, viewW * HeightScale);
        self.playerLayer.frame = CGRectMake(0, 0, viewW, viewW * HeightScale);
        
        if (self.lastOrientation == UIInterfaceOrientationLandscapeLeft) {
            self.transform = CGAffineTransformMakeRotation(-M_PI_4);
        } else if (self.lastOrientation == UIInterfaceOrientationLandscapeRight) {
            self.transform = CGAffineTransformMakeRotation(M_PI_4 * 0.5);
        }
        
        [UIView animateWithDuration:duration animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
        }];
        self.lastOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if (!self.isTopViewHidden) {
            self.topView.frame = CGRectMake(0, 20, viewW, BottomH);
            self.bottomView.frame = CGRectMake(0, viewW * HeightScale - BottomH, viewW, BottomH);
        } else {
            self.topView.frame = CGRectMake(0, -BottomH, viewW, BottomH);
            self.bottomView.frame = CGRectMake(0, viewW * HeightScale, viewW, BottomH);
        }
        
        self.lockButton.hidden = YES;
        CGRect lockButtonRect = self.lockButton.frame;
        lockButtonRect.origin.x = -BottomH * 1.2;
        self.lockButton.frame = lockButtonRect;
        
    } else {
        //横屏
        spaceW = 5;
        CGFloat leftW = 0;
        CGFloat bottomH = 0;
        if (IPHONE_X) {
            leftW = 44;
            bottomH = 21;;
        }
        
        CGRect frame = CGRectMake(leftW, 0, viewH - leftW * 2, viewW - bottomH);
        self.frame = frame;
        self.playerLayer.frame = frame;
        self.transform = CGAffineTransformMakeRotation(-M_PI_4 * 0.5);
        
        if (self.lastOrientation == UIInterfaceOrientationPortrait) {
            
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
                self.transform = CGAffineTransformMakeRotation(M_PI_4 * 0.5);
            } else if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
                self.transform = CGAffineTransformMakeRotation(-M_PI_4 * 0.5);
            }
            
        } if (self.lastOrientation == UIInterfaceOrientationLandscapeLeft || self.lastOrientation == UIInterfaceOrientationLandscapeRight) {
            
            self.transform = CGAffineTransformMakeRotation(M_PI_4);
        }
        [UIView animateWithDuration:duration animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
        }];
        self.lastOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
        
        self.lockButton.hidden = NO;
        if (!self.isTopViewHidden) {
            CGRect lockButtonRect = self.lockButton.frame;
            lockButtonRect.origin.x = BottomH * 0.5;
            
            [UIView animateWithDuration:duration * 2 animations:^{
                self.lockButton.frame = lockButtonRect;
            }];
            
            self.topView.frame = CGRectMake(0, 20, viewW - leftW * 2, BottomH);
            self.bottomView.frame = CGRectMake(0, viewW - BottomH - bottomH, viewH - leftW * 2, BottomH);
            
        } else {
            self.topView.frame = CGRectMake(0, -BottomH, viewW - leftW * 2, BottomH);
            self.bottomView.frame = CGRectMake(0, viewW - bottomH, viewH - leftW * 2, BottomH);
        }
    }
    
    CGSize frameSize = self.frame.size;
    
    self.playButton.center = CGPointMake(spaceW + BottomH * 0.5, BottomH * 0.5);
    self.rotationButton.center = CGPointMake(frameSize.width - BottomH * 0.5 - spaceW, BottomH * 0.5);
    
    self.currentTimeLabel.frame = CGRectMake(CGRectGetMaxX(_playButton.frame) + spaceW, 0, 40, BottomH);
    self.totalTimeLabel.frame = CGRectMake(CGRectGetMinX(_rotationButton.frame) - 40 - spaceW, 0, 40, BottomH);
    
    CGRect sliderFrame = CGRectMake(0, 0, frameSize.width - BottomH * 2 - spaceW * 4 - 90, 20);
    CGPoint sliderCenter = CGPointMake(frameSize.width * 0.5, BottomH * 0.5);
    
    self.loadingView.bounds = sliderFrame;
    self.loadingView.center = sliderCenter;
    
    self.playSlider.bounds = CGRectMake(0, 0, CGRectGetWidth(sliderFrame) + 6, 20);
    self.playSlider.center = sliderCenter;
    
    [self delayExecute];
}

#pragma mark
- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        
        NSURL *url;
        if ([self.fileUrl hasPrefix:@"http"]) {
            url = [NSURL URLWithString:self.fileUrl];
        } else {
            url = [NSURL fileURLWithPath:self.fileUrl];
        }
        
        _playerItem = [AVPlayerItem playerItemWithURL:url];
        _player = [AVPlayer playerWithPlayerItem:_playerItem];
        
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.frame = CGRectMake(0, 0, viewW, viewW * HeightScale);
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _playerLayer;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_player removeTimeObserver:playerTimeObserver];
    
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
}

- (BOOL)willDealloc {
    return NO;
}

@end
