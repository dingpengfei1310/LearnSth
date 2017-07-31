//
//  VideoScanController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/2/14.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "VideoScanController.h"
#import "FilterCollectionView.h"

#import <GPUImage.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoScanController () {
    CGFloat viewW;
    CGFloat viewH;
}

@property (nonatomic, strong) GPUImageMovie *movie;
@property (nonatomic, strong) GPUImageView *videoView;

@property (nonatomic, strong) AVURLAsset *urlAsset;
@property (nonatomic, strong) AVPlayer *player;//为了播放声音

@property (nonatomic, strong) NSArray *filterArray;
@property (nonatomic, assign) NSInteger filterIndex;

@property (nonatomic, strong) UIButton *playButton;

@end

@implementation VideoScanController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    viewW = self.view.frame.size.width;
    viewH = self.view.frame.size.height;
    
    [self setBackgropundImage];
    
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:self.asset options:options resultHandler:^(AVAsset * asset, AVAudioMix * audioMix, NSDictionary * info) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            AVURLAsset *urlAsset = (AVURLAsset *)asset;
            self.urlAsset = urlAsset;
            
            [self addVideoViewWith:urlAsset.URL];
            [self addButton];
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark
- (void)setBackgropundImage {
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:backgroundImageView];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    options.synchronous = YES;
    
    //模糊图
    [[PHImageManager defaultManager] requestImageForAsset:self.asset
                                               targetSize:CGSizeZero
                                              contentMode:PHImageContentModeAspectFit
                                                  options:options
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                backgroundImageView.image = result;
                                            }];
    //清晰图，耗时长
    [[PHImageManager defaultManager] requestImageDataForAsset:self.asset options:nil resultHandler:^(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info) {
        UIImage *image = [UIImage imageWithData:imageData];
        backgroundImageView.image = image;
    }];
}

- (void)addVideoViewWith:(NSURL *)url {
    self.filterArray = @[
                         @{@"name":@"普通",@"className":[GPUImageFilter class]},
                         @{@"name":@"素描",@"className":[GPUImageSketchFilter class]},
                         @{@"name":@"怀旧",@"className":[GPUImageSepiaFilter class]},
                         @{@"name":@"浮雕",@"className":[GPUImageEmbossFilter class]},
                         @{@"name":@"像素",@"className":[GPUImagePixellateFilter class]},
                         @{@"name":@"卡通",@"className":[GPUImageSmoothToonFilter class]}
                         ];
    
    _videoView = [[GPUImageView alloc] init];
    //如果不用下面这几句代码，画面会逆时针旋转90度
    _videoView.frame = CGRectMake(0, 0, viewH, viewW);
    _videoView.transform = CGAffineTransformMakeRotation(M_PI_2);
    _videoView.center = CGPointMake(viewW * 0.5, viewH * 0.5);
    [self.view addSubview:_videoView];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    _player = [AVPlayer playerWithPlayerItem:playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidPlayToEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
//    _movie = [[GPUImageMovie alloc] initWithURL:url];
    _movie = [[GPUImageMovie alloc] initWithPlayerItem:playerItem];
    _movie.playAtActualSpeed = YES;
    _movie.runBenchmark = YES;
}

- (void)addButton {
    CGFloat buttonW = 40;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, viewH - buttonW * 2, viewW, buttonW)];
    bottomView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
    [self.view addSubview:bottomView];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonW, buttonW)];
    backButton.center = CGPointMake(viewW / 4, buttonW / 2);
    [backButton setTitle:@"取消" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:backButton];
    
    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonW, buttonW)];
    playButton.center = CGPointMake(viewW / 4 * 3, buttonW / 2);
    [playButton setTitle:@"播放" forState:UIControlStateNormal];
    [playButton setTitle:@"暂停" forState:UIControlStateSelected];
    [playButton addTarget:self action:@selector(videoPaly:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:playButton];
    _playButton = playButton;
    
    FilterCollectionView *filterView = [[FilterCollectionView alloc] initWithFrame:CGRectMake(0, viewH - buttonW, viewW, buttonW)
                                                                           filters:_filterArray];
    filterView.FilterSelect = ^(NSInteger index){
        [self changeFilterWith:index];
    };
    [self.view addSubview:filterView];
}

#pragma mark
- (void)back {
    [self.player pause];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)playerDidPlayToEnd {
    _playButton.selected = NO;
    [self.player seekToTime:CMTimeMake(0, 1)];
}

//播放
- (void)videoPaly:(UIButton *)button {
    button.selected = !button.selected;
    
    if (self.player.rate) {
        [self.player pause];
    } else {
        [self.movie removeAllTargets];
        
        if (self.filterIndex == 0) {
            [self.movie addTarget:self.videoView];
        } else {
            NSDictionary *filterInfo = self.filterArray[self.filterIndex];
            Class filterClass = filterInfo[@"className"];
            GPUImageFilter *currentFilter = [[filterClass alloc] init];
            
            [self.movie addTarget:currentFilter];
            [currentFilter addTarget:self.videoView];
        }
        
        [self.movie startProcessing];
        [self.player play];
    }
}

- (void)changeFilterWith:(NSInteger)index {
    if (self.filterIndex == index) {
        return;
    }
    self.filterIndex = index;
    
    if (index == 0) {
        [self normalVieoPlay];
        
        if (!self.player.rate) {
            [self changeFilterWhenVideoIsPause];
        }
    } else {
        NSDictionary *filterInfo = self.filterArray[index];
        Class filterClass = filterInfo[@"className"];
        GPUImageFilter *currentFilter = [[filterClass alloc] init];
        
        [self.movie removeAllTargets];
        [self.movie addTarget:currentFilter];
        [currentFilter addTarget:self.videoView];
        
        if (!self.player.rate) {
            [self changeFilterWhenVideoIsPause];
        }
    }
}

//不加滤镜
- (void)normalVieoPlay {
    [self.movie removeAllTargets];
    [self.movie addTarget:self.videoView];
}

- (void)changeFilterWhenVideoIsPause {
    CMTime currentTime = self.player.currentTime;
    CMTime lastTime = CMTimeMake(currentTime.value - 1, currentTime.timescale);
    
    [self.player seekToTime:lastTime];
    [self.player seekToTime:currentTime];
    
    [self.movie startProcessing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
