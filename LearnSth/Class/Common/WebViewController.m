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
#import "UIViewController+PopAction.h"

@interface WebViewController ()<WKNavigationDelegate,UIGestureRecognizerDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *KWebView;
@property (nonatomic, strong) WebProgressView *progressView;

@end

static NSString *EstimatedProgress = @"estimatedProgress";

@implementation WebViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.urlString) {
        self.urlString = [self.urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *url = [NSURL URLWithString:self.urlString];
        [self.KWebView loadRequest:[NSURLRequest requestWithURL:url]];
        
        [self.view addSubview:self.KWebView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.progressView removeFromSuperview];
}

- (BOOL)navigationShouldPopItem {
    if ([self.KWebView canGoBack]) {
        [self.KWebView goBack];
        return NO;
        
    } else {
        return YES;
    }
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
    
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id title, NSError * error) {
        if (!self.title) {
            self.navigationItem.title = title;
        }
    }];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"WKUserContentController:%@",message);
}

#pragma mark
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

#pragma mark
- (WKWebView *)KWebView {
    if (!_KWebView) {
        _KWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
        _KWebView.navigationDelegate = self;
//        _KWebView.allowsBackForwardNavigationGestures = YES;//左滑goBack，右滑。。。
        [_KWebView addObserver:self forKeyPath:EstimatedProgress options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return _KWebView;
}

- (WebProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[WebProgressView alloc] initWithFrame:CGRectMake(0, 61, self.view.frame.size.width, 3)];
    }
    return _progressView;
}

#pragma mark
- (void)dealloc {
    [self.KWebView removeObserver:self forKeyPath:EstimatedProgress];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
