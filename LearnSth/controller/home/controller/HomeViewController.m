//
//  ViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "HomeViewController.h"

#import "AnimationView.h"

@interface HomeViewController ()

@property (nonatomic, strong) AnimationView *aView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"00" style:UIBarButtonItemStylePlain target:self action:@selector(popoverController:)];
    
    _aView = [[AnimationView alloc] initWithFrame:CGRectMake(20, 84, 100, 100)];
    [self.view addSubview:_aView];
    
//    [_aView startColorfulProgress];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
