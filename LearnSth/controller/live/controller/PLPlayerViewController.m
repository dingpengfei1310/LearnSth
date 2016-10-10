//
//  PLPlayerViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "PLPlayerViewController.h"

#import <PLPlayerKit/PLPlayerKit.h>

@interface PLPlayerViewController ()<PLPlayerDelegate>

@property (nonatomic, strong) PLPlayer *player;

@end

@implementation PLPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PLPlayerOption *option = [PLPlayerOption defaultOption];
    [option setOptionValue:@15 forKey:PLPlayerOptionKeyTimeoutIntervalForMediaPackets];
    NSURL *url = [NSURL URLWithString:self.live.flv];
    self.player = [PLPlayer playerWithURL:url option:option];
    self.player.delegate = self;
    
    [self.view addSubview:self.player.playerView];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
