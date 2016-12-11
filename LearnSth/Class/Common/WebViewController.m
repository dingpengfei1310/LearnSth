//
//  WebViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/12.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
#import "WebProgressView.h"

@interface WebViewController ()<WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *KWebView;
@property (nonatomic, strong) WebProgressView *progressView;

@end

static NSString *EstimatedProgress = @"estimatedProgress";

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setLeftItemsWithCanGoBack:NO];
    
    if (self.urlString) {
        NSURL *url = [NSURL URLWithString:self.urlString];
        [self.KWebView loadRequest:[NSURLRequest requestWithURL:url]];
        
        [self.view addSubview:self.KWebView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.progressView removeFromSuperview];
}

#pragma mark
- (void)setLeftItemsWithCanGoBack:(BOOL)flag {
    UIImage *image = [UIImage imageNamed:@"backButtonImage"];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(webBackClick)];
    if (flag) {
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeController)];
        self.navigationItem.leftBarButtonItems = @[item,closeItem];
        
    } else {
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.leftBarButtonItem = item;
    }
}

- (void)webBackClick {
    if ([self.KWebView canGoBack]) {
        [self.KWebView goBack];
    } else {
        [self closeController];
    }
}

- (void)closeController {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:EstimatedProgress]) {
        self.progressView.progress = self.KWebView.estimatedProgress;
    }
}

#pragma mark WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self.progressView removeFromSuperview];
    self.progressView.progress = 0;
    [self.navigationController.view addSubview:self.progressView];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.progressView removeFromSuperview];
    [self setLeftItemsWithCanGoBack:[webView canGoBack]];
}

#pragma mark
- (void)dealloc {
    [self.KWebView removeObserver:self forKeyPath:EstimatedProgress];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark
- (WKWebView *)KWebView {
    if (!_KWebView) {
        _KWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, ViewFrameOrigin_X, ScreenWidth, ScreenHeight - 64)];
        _KWebView.navigationDelegate = self;
        _KWebView.scrollView.showsVerticalScrollIndicator = NO;
        [_KWebView addObserver:self forKeyPath:EstimatedProgress options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return _KWebView;
}

- (WebProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[WebProgressView alloc] initWithFrame:CGRectMake(0, 62 + ViewFrameOrigin_X, ScreenWidth, 2)];
    }
    return _progressView;
}

@end




