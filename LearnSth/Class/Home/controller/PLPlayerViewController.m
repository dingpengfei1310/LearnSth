//
//  PLPlayerViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "PLPlayerViewController.h"
#import "ShoppingViewController.h"
#import "LiveModel.h"

#import <PLPlayerKit/PLPlayerKit.h>

@interface PLPlayerViewController ()<PLPlayerDelegate>

@property (nonatomic, strong) LiveModel *live;

@property (nonatomic, strong) PLPlayer *player;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, assign) CGPoint lastPanPoint;

@end

//const NSInteger PlayerViewTag = 99999;
const CGFloat PlayerViewScale = 0.4;//缩小后的view宽度占屏幕宽度的比例

@implementation PLPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.live = self.liveArray[self.index];
    self.title = self.live.myname;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dismiss"] style:UIBarButtonItemStylePlain target:self action:@selector(dismisss)];
    
    [self.view addSubview:self.player.playerView];
    [self.view addSubview:self.backgroundImageView];
    
    [self addGesture];
}

- (void)addGesture {
    UISwipeGestureRecognizer *dismissGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismisss)];
    dismissGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:dismissGesture];
    
    UISwipeGestureRecognizer *nextGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextLive)];
    nextGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:nextGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self navigationBarColorClear];
    [self.player play];
    self.player.playerView.gestureRecognizers = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self navigationBarColorRestore];
}

#pragma mark
- (void)dismisss {
    [self.player stop];
    if (self.PlayerDismissBlock) {
        self.PlayerDismissBlock();
    }
}

- (void)smallView:(UIBarButtonItem *)sender {
    [self.player.playerView removeFromSuperview];
    [self.window addSubview:self.player.playerView];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.player.playerView.frame = CGRectMake((1 - PlayerViewScale) * Screen_W, 64, Screen_W * PlayerViewScale, Screen_H * PlayerViewScale);
    } completion:^(BOOL finished) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePlayerView:)];
        [self.player.playerView addGestureRecognizer:panGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPlayerView:)];
        [self.player.playerView addGestureRecognizer:tapGesture];
    }];
    
    ShoppingViewController *controller = [[ShoppingViewController alloc] init];
    controller.BackItemBlock = ^{
        [self backToRootController];
    };
    [self.navigationController pushViewController:controller animated:NO];
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
        
        if (Center_X < Screen_W * scale) {
            Center_X = Screen_W * scale;
        } else if (Center_X > Screen_W * (1 - scale)) {
            Center_X = Screen_W * (1 - scale);
        }
        
        if (Center_Y < Screen_H * scale) {
            Center_Y = Screen_H * scale;
        } else if (Center_Y > Screen_H * (1 - scale)) {
            Center_Y = Screen_H * (1 - scale);
        }
        
        self.player.playerView.center = CGPointMake(Center_X, Center_Y);
    }
    
    self.lastPanPoint = point;
}

- (void)clickPlayerView:(UITapGestureRecognizer *)gestureRecognizer {
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
        self.live = self.liveArray[self.index];
        
        self.title = self.live.myname;
        self.navigationItem.rightBarButtonItem = nil;
        [self.view addSubview:self.backgroundImageView];
        
        NSURL *url = [NSURL URLWithString:self.live.flv];
        [self.player playWithURL:url];
        
    } else {
        [self showError:@"没有更多数据"];
    }
}

#pragma mark
- (void)player:(PLPlayer *)player statusDidChange:(PLPlayerStatus)state {
    if (state == PLPlayerStatusPlaying) {
        [self.backgroundImageView removeFromSuperview];
        self.backgroundImageView = nil;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(smallView:)];
    }
}

#pragma mark
- (PLPlayer *)player {
    if (!_player) {
        PLPlayerOption *option = [PLPlayerOption defaultOption];
//        [option setOptionValue:@1 forKey:PLPlayerOptionKeyVideoToolbox];
        
        NSURL *url = [NSURL URLWithString:self.live.flv];
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

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.live.bigpic]];
        UIImage *image = [UIImage imageWithData:data];
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImageView.image = image;
        
        UIBlurEffect *beffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:beffect];
        blurView.frame = self.view.bounds;
        
        [_backgroundImageView addSubview:blurView];
    }
    return _backgroundImageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
