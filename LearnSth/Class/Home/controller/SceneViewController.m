//
//  SceneViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/5/26.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "SceneViewController.h"
#import "SceneGameView.h"
#import "SceneRainView.h"

@interface SceneViewController ()

@end

@implementation SceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"小怪兽";
    
//    SceneGameView *gameView = [[SceneGameView alloc] initWithFrame:CGRectMake(0, 64, Screen_W, Screen_H - 64)];
//    [self.view addSubview:gameView];
    
    SceneRainView *gameView = [[SceneRainView alloc] initWithFrame:CGRectMake(0, 64, Screen_W, Screen_H - 64)];
    [self.view addSubview:gameView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
