//
//  VideoProcessWithFilter.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/5/9.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "VideoProcessWithFilter.h"
#import "FilterCollectionView.h"
#import "GPUImageBeautifyFilter.h"

#import <GPUImage.h>
#import <Photos/Photos.h>

@interface VideoProcessWithFilter ()

@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic, strong) AVURLAsset *urlAsset;

@property (nonatomic, strong) NSArray *filterArray;
@property (nonatomic, assign) NSInteger filterIndex;

@end

@implementation VideoProcessWithFilter

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"滤镜";
    
    _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    //    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_backgroundImageView];
    
    if (self.filePath) {
        NSURL *url = [NSURL fileURLWithPath:self.filePath];
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        self.urlAsset = urlAsset;
        
        _originalImage = [self getVideoPreViewImage:url];
        _backgroundImageView.image = _originalImage;
        
        [self initFilterView];
        
    } else {
        [self setBackgropundImage];
        
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:self.asset options:options resultHandler:^(AVAsset * asset, AVAudioMix * audioMix, NSDictionary * info) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                AVURLAsset *urlAsset = (AVURLAsset *)asset;
                self.urlAsset = urlAsset;
                
                [self initFilterView];
            });
            
        }];
    }
}

#pragma mark
- (UIImage *)getVideoPreViewImage:(NSURL *)url {
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:NULL error:nil];
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return image;
}

#pragma mark
- (void)setBackgropundImage {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    options.synchronous = YES;
    
    //模糊图
    [[PHImageManager defaultManager] requestImageForAsset:self.asset
                                               targetSize:CGSizeZero
                                              contentMode:PHImageContentModeAspectFit
                                                  options:options
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                _originalImage = result;
                                                _backgroundImageView.image = result;
                                            }];
    
    //清晰图，耗时长
    [[PHImageManager defaultManager] requestImageDataForAsset:self.asset options:nil resultHandler:^(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info) {
        UIImage *image = [UIImage imageWithData:imageData];
        _originalImage = image;
        _backgroundImageView.image = image;
    }];
}

- (void)initFilterView {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"00" style:UIBarButtonItemStylePlain target:self action:@selector(videoFilter)];
    
    _filterArray = @[
                 @{@"name":@"普通",@"className":[GPUImageBrightnessFilter class]},
                 @{@"name":@"美颜",@"className":[GPUImageBeautifyFilter class]},
                 @{@"name":@"素描",@"className":[GPUImageSketchFilter class]},
                 @{@"name":@"怀旧",@"className":[GPUImageSepiaFilter class]},
                 @{@"name":@"浮雕",@"className":[GPUImageEmbossFilter class]},
                 @{@"name":@"像素",@"className":[GPUImagePixellateFilter class]},
                 @{@"name":@"卡通",@"className":[GPUImageSmoothToonFilter class]}
                 ];
    
    FilterCollectionView *filterView = [[FilterCollectionView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, self.view.frame.size.width, 40)];
    filterView.filters = _filterArray;
    filterView.FilterSelect = ^(NSInteger index){
        [self changeFilterWith:index];
    };
    [self.view addSubview:filterView];
}

- (void)changeFilterWith:(NSInteger)index {
    if (self.filterIndex == index || !_originalImage) {
        return;
    }

    self.filterIndex = index;
    NSDictionary *filterInfo = self.filterArray[index];
    Class filterClass = filterInfo[@"className"];
    GPUImageFilter *currentFilter = [[filterClass alloc] init];
    
    if (index == 0) {
        GPUImageBrightnessFilter *brightnessFilter = (GPUImageBrightnessFilter *)currentFilter;
        brightnessFilter.brightness = 0.0;
    }
    
    //设置要渲染的区域
//    [currentFilter forceProcessingAtSize:_originalImage.size];
    [currentFilter useNextFrameForImageCapture];
    
    //获取数据源
    GPUImagePicture *imagePicture = [[GPUImagePicture alloc] initWithImage:_originalImage];
    [imagePicture addTarget:currentFilter];
    [imagePicture processImage];
    
    UIImage *newImage = [currentFilter imageFromCurrentFramebuffer];
    _backgroundImageView.image = newImage;
}

//转换
- (void)videoFilter {
    [self loadingWithText:@"处理中.."];
    
    //这里必须用initWithURL，不然就不对。。不知道原因。
    GPUImageMovie *movieFile = [[GPUImageMovie alloc] initWithURL:self.urlAsset.URL];
    movieFile.playAtActualSpeed = NO;
    movieFile.runBenchmark = YES;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.width - 40) / 2, self.view.frame.size.height, 40)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:20];
    label.textColor = [UIColor redColor];
    label.text = @"长风破浪会有时，直挂云帆济沧海";
    label.transform = CGAffineTransformMakeRotation(-M_PI_4);
    [contentView addSubview:label];
    
    //滤镜
    NSDictionary *filterInfo = self.filterArray[_filterIndex];
    Class filterClass = filterInfo[@"className"];
    GPUImageFilter *currentFilter = [[filterClass alloc] init];
    
    if (_filterIndex == 0) {
        GPUImageBrightnessFilter *brightnessFilter = (GPUImageBrightnessFilter *)currentFilter;
        brightnessFilter.brightness = 0.0;
    }
    [movieFile addTarget:currentFilter];
    
    //水印
    GPUImageUIElement *element = [[GPUImageUIElement alloc] initWithView:contentView];
    GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    blendFilter.mix = 1.0;
    
    [currentFilter addTarget:blendFilter];
    [element addTarget:blendFilter];
    
    [blendFilter addTarget:self.movieWriter];
    
    [currentFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        [element updateWithTimestamp:time];
    }];
    
    //声音
    movieFile.audioEncodingTarget = self.movieWriter;
    
    [movieFile startProcessing];
    //如果使用这个方法，[self.movieWriter startRecording];画面会逆时针旋转90度。
    //这个方法，手动顺时针旋转90度。
    [self.movieWriter startRecordingInOrientation:CGAffineTransformMakeRotation(M_PI_2)];
}

#pragma mark
- (GPUImageMovieWriter *)movieWriter {
    if (!_movieWriter) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm:ss"];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@-滤镜.mov",dateString];
//        NSString *fileName = @"转换.mov";
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
        _movieWriter.shouldPassthroughAudio = YES;
        
        __weak typeof(self) wSelf = self;
        [_movieWriter setCompletionBlock:^{
            [wSelf.movieWriter finishRecording];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [wSelf hideHUD];
                [wSelf showSuccess:@"处理完成"];
                [wSelf.navigationController popViewControllerAnimated:YES];
            });
        }];
    }
    
    return _movieWriter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
