//
//  LiveViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/28.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "LiveViewController.h"

#import "HttpRequestManager.h"
#import "LiveModel.h"

#import "UIImageView+AFNetworking.h"

#import "PLPlayerViewController.h"

@interface LiveViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

//@property (nonatomic, strong) PLCameraStreamingSession *session;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *list;

@end

static NSString *identifier = @"cell";


@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//#if TARGET_IPHONE_SIMULATOR
//
//#elif TARGET_OS_IPHONE
//    
//    PLVideoCaptureConfiguration *videoCaptureConfiguration = [PLVideoCaptureConfiguration defaultConfiguration];
//    PLAudioCaptureConfiguration *audioCaptureConfiguration = [PLAudioCaptureConfiguration defaultConfiguration];
//    PLVideoStreamingConfiguration *videoStreamingConfiguration = [PLVideoStreamingConfiguration defaultConfiguration];
//    PLAudioStreamingConfiguration *audioStreamingConfiguration = [PLAudioStreamingConfiguration defaultConfiguration];
//    
//    self.session = [[PLCameraStreamingSession alloc] initWithVideoCaptureConfiguration:videoCaptureConfiguration audioCaptureConfiguration:audioCaptureConfiguration videoStreamingConfiguration:videoStreamingConfiguration audioStreamingConfiguration:audioStreamingConfiguration stream:nil videoOrientation:AVCaptureVideoOrientationPortrait];
//#endif
    
    CGFloat itemWidth = (self.view.frame.size.width - 30) / 2;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:identifier];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.view addSubview:_collectionView];
    
    [[HttpRequestManager shareManager] getHotLiveListWithParamer:nil success:^(id responseData) {
        NSArray *array = [LiveModel liveWithArray:responseData];
        self.list = [NSArray arrayWithArray:array];
        [self.collectionView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.list.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    LiveModel *model = self.list[indexPath.item];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
//    [imageView sd_setImageWithURL:[NSURL URLWithString:model.smallpic] placeholderImage:nil];
    [imageView setImageWithURL:[NSURL URLWithString:model.smallpic] placeholderImage:nil];
    [cell.contentView addSubview:imageView];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PLPlayerViewController *controller = [[PLPlayerViewController alloc] init];
    controller.live = self.list[indexPath.item];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [self.view addSubview:self.session.previewView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
