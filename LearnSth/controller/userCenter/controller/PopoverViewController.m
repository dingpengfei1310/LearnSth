//
//  PopoverViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/26.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "PopoverViewController.h"

@interface PopoverViewController () {
    CGFloat viewWidth;
    CGFloat ViewHeight;
}

@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation PopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.textAlignment = NSTextAlignmentCenter;
    _contentLabel.text = self.content;
    _contentLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:_contentLabel];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    viewWidth = CGRectGetWidth(self.view.frame);
    ViewHeight = CGRectGetHeight(self.view.frame);
    
    _contentLabel.frame = CGRectMake(0, 10, viewWidth, 30);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
