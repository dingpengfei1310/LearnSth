//
//  ShoppingViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/2/8.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "ShoppingViewController.h"
#import "MessageViewController.h"

@interface ShoppingViewController ()

@end

@implementation ShoppingViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"shop";
    //如果没有自定义返回按钮，则要设置
//    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backButtonImage"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClick:)];
}

#pragma mark
- (void)back:(UIBarButtonItem *)sender {
    if (self.BackItemBlock) {
        self.BackItemBlock();
    }
}

- (void)addClick:(UIBarButtonItem *)sender {
    MessageViewController *controller = [[MessageViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
