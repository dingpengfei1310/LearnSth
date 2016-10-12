//
//  WebViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/12.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [self.view addSubview:_webView];
    
    NSURL *url = [NSURL URLWithString:self.urlString];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    NSLog(@"%@",self.urlString);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
