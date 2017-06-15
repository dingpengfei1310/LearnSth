//
//  ShoppingViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/2/8.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "ShoppingViewController.h"
#import "MessageViewController.h"
#import "UIViewController+PopAction.h"

@interface ShoppingViewController ()

@end

@implementation ShoppingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"shop";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClick:)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

#pragma mark
- (void)addClick:(UIBarButtonItem *)sender {
    MessageViewController *controller = [[MessageViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark
- (BOOL)navigationShouldPopItem {
    if (self.BackItemBlock) {
        self.BackItemBlock();
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
