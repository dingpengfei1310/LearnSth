//
//  WebViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/12.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>

@interface WebViewController ()<WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *KWebView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.urlString) {
        _KWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
        _KWebView.navigationDelegate = self;
        [self.view addSubview:_KWebView];
        
        NSURL *url = [NSURL URLWithString:self.urlString];
        [_KWebView loadRequest:[NSURLRequest requestWithURL:url]];
        
        NSLog(@"%@",self.urlString);
//        [self loading];
    }
}

#pragma mark
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self hideHUD];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
