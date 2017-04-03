//
//  RotationViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/31.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "RotationViewController.h"
#import "AppDelegate.h"
#import "UIViewController+PopAction.h"

@interface RotationViewController ()

@end

@implementation RotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
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
- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        //横
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    } else {
        //竖
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

#pragma mark
- (BOOL)navigationShouldPopItem {
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
