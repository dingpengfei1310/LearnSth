//
//  ImageViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/27.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "ImageViewController.h"

#import "GPUImage.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIImage *inputImage = [UIImage imageNamed:@"000.jpg"];
    
//    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
////    GPUImageSepiaFilter *stillImageFilter = [[GPUImageSepiaFilter alloc] init];
//    GPUImageAverageLuminanceThresholdFilter *stillImageFilter = [[GPUImageAverageLuminanceThresholdFilter alloc] init];
//    [stillImageFilter forceProcessingAtSize:CGSizeMake(750, 750)];
//    
//    
//    [stillImageSource addTarget:stillImageFilter];
//    [stillImageFilter useNextFrameForImageCapture];
//    [stillImageSource processImage];
//    
//    UIImage *currentFilteredVideoFrame = [stillImageFilter imageFromCurrentFramebuffer];
    
    
//    GPUImageSepiaFilter *stillImageFilter2 = [[GPUImageSepiaFilter alloc] init];
//    UIImage *quickFilteredImage = [stillImageFilter2 imageByFilteringImage:inputImage];
//    
//    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, 320, 320)];
//    imageView.contentMode = UIViewContentModeScaleAspectFill;
//    imageView.image = quickFilteredImage;
//    [self.view addSubview:imageView];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
