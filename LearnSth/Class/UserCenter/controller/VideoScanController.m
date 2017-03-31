//
//  VideoScanController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/2/14.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "VideoScanController.h"
#import "FilterCollectionView.h"
#import "GPUImage.h"

#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoScanController ()

@property (nonatomic, strong) GPUImageMovie *movie;
@property (nonatomic, strong) GPUImageView *videoView;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;

@property (nonatomic, strong) AVPlayer *player;//为了播放声音

@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, strong) NSArray *imageFilters;
@property (nonatomic, assign) NSInteger filterIndex;
@property (nonatomic, strong) GPUImageFilter *currentFilter;

@property (nonatomic, strong) AVURLAsset *urlAsset;

@end

@implementation VideoScanController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    self.filterIndex = 0;
    self.imageFilters = @[
                          @{@"name":@"普通",@"className":[GPUImageFilter class]},
                          @{@"name":@"素描",@"className":[GPUImageSketchFilter class]},
                          @{@"name":@"怀旧",@"className":[GPUImageSepiaFilter class]},
                          @{@"name":@"色彩丢失",@"className":[GPUImageColorPackingFilter class]},
                          @{@"name":@"浮雕3D",@"className":[GPUImageEmbossFilter class]},
                          @{@"name":@"像素",@"className":[GPUImagePixellateFilter class]},
                          @{@"name":@"卡通",@"className":[GPUImageSmoothToonFilter class]}
                          ];
    
    _videoView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, Screen_W, Screen_H)];
    
    //如果不用下面这几句代码，画面会逆时针旋转90度
    _videoView.frame = CGRectMake(0, 0, Screen_H, Screen_W);
    _videoView.transform = CGAffineTransformMakeRotation(M_PI_2);
    _videoView.center = CGPointMake(Screen_W * 0.5, Screen_H * 0.5);
    
    [self.view addSubview:_videoView];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    _player = [AVPlayer playerWithPlayerItem:playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidPlayToEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
//    _movie = [[GPUImageMovie alloc] initWithURL:url];
    _movie = [[GPUImageMovie alloc] initWithPlayerItem:playerItem];
    _movie.playAtActualSpeed = YES;
    
}

- (void)addButton {
    CGFloat viewWidth = Screen_W;
    CGFloat viewHeight = Screen_H;
    CGFloat buttonWidth = 50;
    CGFloat buttonHeight = 40;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight - buttonHeight, viewWidth, buttonHeight)];
    bottomView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
    [self.view addSubview:bottomView];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    backButton.center = CGPointMake(viewWidth / 6, buttonHeight / 2);
    [backButton setTitle:@"取消" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:backButton];
    
    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    playButton.center = CGPointMake(viewWidth / 6 * 3, buttonHeight / 2);
    [playButton setTitle:@"播放" forState:UIControlStateNormal];
    [playButton setTitle:@"暂停" forState:UIControlStateSelected];
    [playButton addTarget:self action:@selector(videoPaly:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:playButton];
    _playButton = playButton;
    
//    UIButton *filterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, 30)];
//    filterButton.center = CGPointMake(viewWidth / 6 * 5, 25);
//    [filterButton setTitle:@"转换" forState:UIControlStateNormal];
//    [filterButton setTitle:@"暂停" forState:UIControlStateSelected];
//    [filterButton addTarget:self action:@selector(videoFilter:) forControlEvents:UIControlEventTouchUpInside];
//    [bottomView addSubview:filterButton];
    
    FilterCollectionView *filterView = [[FilterCollectionView alloc] initWithFrame:CGRectMake(0, viewHeight - 90, viewWidth, 50)];
    filterView.filters = self.imageFilters;
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
        [self.movie startProcessing];
        [self.movie removeAllTargets];
        
        if (self.currentFilter) {
            [self.movie addTarget:self.currentFilter];
            [self.currentFilter addTarget:self.videoView];
        } else {
            [self.movie addTarget:self.videoView];
        }
        
        [self.player play];
    }
}

#pragma mark改变滤镜
- (void)changeFilterWith:(NSInteger)index {
    if (self.filterIndex == index) {
        return;
    }
    self.filterIndex = index;
    
    if (index == 0) {
        self.currentFilter = nil;
        [self normalCamera];
        return;
    }
    
    NSDictionary *filterInfo = self.imageFilters[index];
    Class filterClass = filterInfo[@"className"];
    
    GPUImageFilter *filter = [[filterClass alloc] init];
    self.currentFilter = filter;
    
    [self.movie removeAllTargets];
    
    [self.movie addTarget:filter];
    [filter addTarget:self.videoView];
}

//不加滤镜
- (void)normalCamera {
    [self.movie removeAllTargets];
    
    [self.movie addTarget:self.videoView];
    
    //以下代码：加水印
//    UIView *contentView = [[UIView alloc] initWithFrame:self.videoView.bounds];
//    
//    UIImage *image = [UIImage imageNamed:@"star"];
//    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
//    imageView.image = image;
//    imageView.tag = 500;
//    
//    [contentView addSubview:imageView];
//    
//    GPUImageFilter *filter = [[GPUImageBrightnessFilter alloc] init];
//    
//    GPUImageUIElement *element = [[GPUImageUIElement alloc] initWithView:contentView];
//    GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
//    
//    [blendFilter addTarget:self.videoView];
//    [filter addTarget:blendFilter];
//    [element addTarget:blendFilter];
//    
//    [self.movie addTarget:filter];
//    
//    [filter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
//        [element updateWithTimestamp:time];
//    }];
}

//转换
- (void)videoFilter:(UIButton *)button {
    [self.player pause];
    
    [self loading];
    
    //这里必须用initWithURL，不然就不对。。不知道原因。。同时做播放和转换会出错，最好分开
    GPUImageMovie *filterMovie = [[GPUImageMovie alloc] initWithURL:self.urlAsset.URL];
    
    UIView *contentView = [[UIView alloc] initWithFrame:self.videoView.bounds];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, Screen_W, 100)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:30];
    label.text = @"小飞飞";
//    UIImage *image = [UIImage imageNamed:@"star"];
//
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
//    imageView.image = image;
//    imageView.tag = 500;

    [contentView addSubview:label];
    
    GPUImageFilter *filter = self.currentFilter;
    if (!filter) {
        filter = [[GPUImageBrightnessFilter alloc] init];
    }

    GPUImageUIElement *element = [[GPUImageUIElement alloc] initWithView:contentView];
    GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];

    [blendFilter addTarget:self.movieWriter];
    [filter addTarget:blendFilter];
    [element addTarget:blendFilter];

    [filterMovie addTarget:filter];

    [filter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        [element updateWithTimestamp:time];
    }];
    
    [filterMovie startProcessing];
    //如果使用这个方法，画面会旋转90度。
//    [self.movieWriter startRecording];
    //这个方法，手动旋转90度。
    [self.movieWriter startRecordingInOrientation:CGAffineTransformMakeRotation(M_PI_2)];
}

#pragma mark

- (GPUImageMovieWriter *)movieWriter {
    if (!_movieWriter) {
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateFormat:@"HH:mm:ss"];
//        NSString *dateString = [formatter stringFromDate:[NSDate date]];
//        NSString *fileName = [NSString stringWithFormat:@"%@-转换.mov",dateString];
        NSString *fileName = @"转换.mov";
        NSString *moviePath = [KDocumentPath stringByAppendingPathComponent:fileName];
        unlink([moviePath UTF8String]);
        
        CGSize size = CGSizeZero;
        NSArray *array = [self.urlAsset tracksWithMediaType:AVMediaTypeVideo];
        if (array.count > 0) {
            AVAssetTrack *track = array[0];
            size = track.naturalSize;
        }
        
        NSURL *url = [NSURL fileURLWithPath:moviePath];
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:url size:size];
        
        __weak typeof(self) wSelf = self;
        [_movieWriter setCompletionBlock:^{
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [wSelf hideHUD];
                [wSelf showSuccess:@"转换完成"];
            });
            
        }];
    }
    
    return _movieWriter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
