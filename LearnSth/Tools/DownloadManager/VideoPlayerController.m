//
//  VideoPlayerController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/13.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "VideoPlayerController.h"
#import "AppDelegate.h"
#import "VideoPlayerView.h"

@interface VideoPlayerController () <UITableViewDataSource,UITableViewDelegate>{
    id playerTimeObserver;
}

@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL isLandscape;//是否横屏

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) VideoPlayerView *playerView;

@end

@implementation VideoPlayerController

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
    
    self.dataArray = @[@"",@"",@"",@"",@""];
    
    [self.view addSubview:self.playerView];
    [self.view addSubview:self.tableView];
    
    [self.view bringSubviewToFront:self.playerView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.isAutorotate = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.isAutorotate = NO;
}

#pragma mark
- (void)backToParentController {
    if (self.isLandscape) {
        [self rotationPlayer];
        
    } else {
        [self.playerView pausePlayer];
        self.BackBlock ? self.BackBlock() : 0;
    }
}

- (void)rotationPlayer {
    self.isLandscape = !self.isLandscape;
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    if (self.isLandscape) {//要转成横屏
        orientation = UIInterfaceOrientationLandscapeRight;
    }
    
    NSNumber *orientationTarget = [NSNumber numberWithInt:orientation];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
}

#pragma mark - 屏幕旋转
- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    
    //横屏:==。。。。竖屏:!=
    self.isLandscape = (newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact);
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    [cell setSeparatorInset:UIEdgeInsetsZero];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = @"rerwerwe";
    
    return cell;
}

#pragma mark - 
- (VideoPlayerView *)playerView {
    if (!_playerView) {
        
        UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, 20)];
        statusBarView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:statusBarView];
        
        __weak typeof(self) wSelf = self;
        _playerView = [[VideoPlayerView alloc] init];
        _playerView.model = self.downloadModel;
        
        _playerView.BackBlock = ^{
            [wSelf backToParentController];
        };
        
        _playerView.FullScreenBlock = ^{
            [wSelf rotationPlayer];
        };
        
        _playerView.TapGestureBlock = ^{
            wSelf.statusBarHidden = !wSelf.statusBarHidden;
            
            [wSelf prefersStatusBarHidden];
            [wSelf setNeedsStatusBarAppearanceUpdate];
        };
        
    }
    return _playerView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_playerView.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(_playerView.frame)) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 50;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
