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
@property (nonatomic, strong) UIProgressView *progressView;

@end

static NSString *EstimatedProgress = @"estimatedProgress";

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.urlString) {
        NSURL *url = [NSURL URLWithString:self.urlString];
        [self.KWebView loadRequest:[NSURLRequest requestWithURL:url]];
        
        [self.view addSubview:self.KWebView];
        [self.view addSubview:self.progressView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:EstimatedProgress]) {
        self.progressView.progress = self.KWebView.estimatedProgress;
    }
}

#pragma mark WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.progressView removeFromSuperview];
}

#pragma mark
- (void)dealloc {
    [self.KWebView removeObserver:self forKeyPath:EstimatedProgress];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark
- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, ViewFrameOrigin_X, ScreenWidth, 5)];
        _progressView.progressTintColor = KBaseBlueColor;
    }
    return _progressView;
}

- (WKWebView *)KWebView {
    if (!_KWebView) {
        _KWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, ViewFrameOrigin_X, ScreenWidth, ScreenHeight - 64)];
        _KWebView.navigationDelegate = self;
        [_KWebView addObserver:self forKeyPath:EstimatedProgress options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return _KWebView;
}


@end
