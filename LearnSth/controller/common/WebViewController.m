//
//  WebViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/12.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>

@interface WebViewController ()<UIAlertViewDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.urlString) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
        [self.view addSubview:_webView];
        
        NSURL *url = [NSURL URLWithString:self.urlString];
        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
        
        NSLog(@"%@",self.urlString);
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
