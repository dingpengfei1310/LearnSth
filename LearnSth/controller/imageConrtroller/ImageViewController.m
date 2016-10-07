//
//  ImageViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/27.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "ImageViewController.h"

#import "GPUImage.h"
#import "FuturesModel.h"

@interface ImageViewController ()<UITableViewDataSource>

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    UIImage *inputImage = [UIImage imageNamed:@"000.jpg"];
    
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
    
    self.dataArray = [NSArray arrayWithArray:[FuturesModel queryFuturesWithPage:1 size:20]];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,
                                                                           self.view.frame.size.width,
                                                                           self.view.frame.size.height)
                                                          style:UITableViewStylePlain];
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.rowHeight = 50;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    FuturesModel *futureModle = self.dataArray[indexPath.row];
    
    cell.textLabel.text = futureModle.contractName;
    cell.detailTextLabel.text = futureModle.updateDate;
    
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
