//
//  ViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "HomeViewController.h"
#import "WebViewController.h"
#import "SearchAddressController.h"

#import "BannerScrollView.h"
#import "HttpManager.h"
#import "ADModel.h"

#import "FoldPaperView.h"
#import "UIView+Origami.h"

@interface HomeViewController ()

@property (nonatomic, copy) NSArray *bannerList;
@property (nonatomic, strong) BannerScrollView *bannerScrollView;

@property (nonatomic, strong) FoldPaperView *foldView;

@end

@implementation HomeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"^_^";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"00" style:UIBarButtonItemStylePlain target:self action:@selector(homeRightItemClick)];
    
    [self.view addSubview:self.bannerScrollView];
    [self getHomeAdBanner];
    
    CGFloat aViewOriginY = CGRectGetMaxY(self.bannerScrollView.frame);
    _foldView = [[FoldPaperView alloc] initWithFrame:CGRectMake(0, aViewOriginY, ScreenWidth, ScreenWidth * 43 / 75)];
    [self.view addSubview:_foldView];
    
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(viewPanHandle:)];
    [self.view addGestureRecognizer:pan];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark
- (void)getHomeAdBanner {
    [[HttpManager shareManager] getAdBannerListCompletion:^(NSArray *list, NSError *error) {
        
        if (error) {
            [self showErrorWithError:error];
        } else {
            NSArray *adArray = [ADModel adWithArray:list];
            self.bannerList = [[NSArray alloc] initWithArray:adArray copyItems:YES];;
            
            NSMutableArray *imageStringArray = [NSMutableArray arrayWithCapacity:self.bannerList.count];
            [self.bannerList enumerateObjectsUsingBlock:^(ADModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [imageStringArray addObject:obj.imageUrl];
            }];
            
            [self.bannerScrollView setImageArray:imageStringArray];
        }
    }];
}

- (void)homeRightItemClick {
//    SearchAddressController *controller = [[SearchAddressController alloc] init];
//    controller.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:controller animated:YES];
    
    [self.foldView showOrigamiTransitionWith:self.view
                               NumberOfFolds:3
                                    Duration:2.0
                                   Direction:XYOrigamiDirectionFromRight
                                  completion:^(BOOL finished) {
                                      //                                        self.closeBtn.hidden = NO;
                                  }];
}

-(void)viewPanHandle:(UIPanGestureRecognizer *) pan{
    CGPoint location = [pan locationInView:self.view];
    CGFloat initialLocation = 0.0;
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        initialLocation = location.x;
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = (location.x - initialLocation) / ScreenWidth;
        
        [self.foldView foldPaperWith:fabs(scale)];
    }
    
}


#pragma mark
- (BannerScrollView *)bannerScrollView {
    if (!_bannerScrollView) {
        _bannerScrollView = [[BannerScrollView alloc] initWithFrame:CGRectMake(0, ViewFrameOrigin_X, ScreenWidth, ScreenWidth * 0.24)];
        
        __weak typeof(self) weakSelf = self;
        _bannerScrollView.imageClickBlock = ^(NSInteger index) {
            
            ADModel *model = weakSelf.bannerList[index];
            if (model.link.length > 0) {
                WebViewController *controller = [[WebViewController alloc] init];
                controller.hidesBottomBarWhenPushed = YES;
                controller.title = model.title;
                controller.urlString = model.link;
                [weakSelf.navigationController pushViewController:controller animated:YES];
            }
        };
    }
    
    return _bannerScrollView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

