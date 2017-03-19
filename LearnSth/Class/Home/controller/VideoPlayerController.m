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

@interface VideoPlayerController () {
    id playerTimeObserver;
}

@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL isLandscape;//是否横屏

//@property (nonatomic, strong) UITableView *tableView;
//@property (nonatomic, strong) NSArray *dataArray;

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
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_H, 20)];
    statusBarView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:statusBarView];
    
    [self.view addSubview:self.playerView];
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
        if (self.BackBlock) {
            self.BackBlock();
        }
    }
}

- (void)rotationPlayer {
    self.isLandscape = !self.isLandscape;
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    if (self.isLandscape) {//要转成横屏
        orientation = UIInterfaceOrientationLandscapeLeft;
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

//#pragma mark
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.dataArray.count;
//}
//
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    [cell setSeparatorInset:UIEdgeInsetsZero];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    }
//    cell.textLabel.text = @"rerwerwe";
//    
//    return cell;
//}

#pragma mark - 
- (VideoPlayerView *)playerView {
    if (!_playerView) {
        
        __weak typeof(self) wSelf = self;
        _playerView = [[VideoPlayerView alloc] init];
        _playerView.name = @"";
        _playerView.urlString = self.urlString;
        
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

//- (UITableView *)tableView {
//    if (!_tableView) {
//        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, Screen_W * PlayerHeightScale + 20, Screen_W, Screen_H - Screen_W * PlayerHeightScale - 20) style:UITableViewStylePlain];
//        _tableView.dataSource = self;
//        _tableView.delegate = self;
//        _tableView.rowHeight = 50;
//        _tableView.tableFooterView = [[UIView alloc] init];
//    }
//    return _tableView;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
