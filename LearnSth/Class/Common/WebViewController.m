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

@interface WebViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *KWebView;
@property (nonatomic, strong) WebProgressView *progressView;

@end

static NSString *EstimatedProgress = @"estimatedProgress";

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.urlString) {
//        _urlString = @"https://m.weibo.cn/n/ever丶飞飞";
        _urlString = [_urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *url = [NSURL URLWithString:self.urlString];
        [self.KWebView loadRequest:[NSURLRequest requestWithURL:url]];

        [self.view addSubview:self.KWebView];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshWebView)];
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
    }
    return YES;
}

- (void)refreshWebView {
    NSURL *url = [NSURL URLWithString:self.urlString];
    [self.KWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:EstimatedProgress]) {
        self.progressView.progress = self.KWebView.estimatedProgress;
    }
}

#pragma mark WKNavigationDelegate
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
//    decisionHandler(WKNavigationActionPolicyAllow);
//}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self.progressView removeFromSuperview];
    self.progressView.progress = 0;
    [self.navigationController.view addSubview:self.progressView];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.progressView removeFromSuperview];
    self.title = webView.title;
//    [webView evaluateJavaScript:@"document.title" completionHandler:^(id title, NSError * error) {
//        self.title = title;
//    }];
//    [webView evaluateJavaScript:@"window.webkit.messageHandlers.currentCookies.postMessage(document.cookie)" completionHandler:nil];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self showSuccess:message.name];
    NSLog(@"WKUserContentController:%@",message.name);
}

#pragma mark WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    completionHandler();
}

#pragma mark
- (WKWebView *)KWebView {
    if (!_KWebView) {
        WKUserContentController *userController = [[WKUserContentController alloc] init];
        WKWebViewConfiguration *configuation = [[WKWebViewConfiguration alloc] init];
        configuation.userContentController = userController;
        
//        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64);
        _KWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuation];
        _KWebView.navigationDelegate = self;
        _KWebView.UIDelegate = self;
//        _KWebView.allowsBackForwardNavigationGestures = YES;//左滑goBack，右滑。。。
        [_KWebView addObserver:self forKeyPath:EstimatedProgress options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        
//        [userController addScriptMessageHandler:self name:@"currentCookies"];
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
//    [self.KWebView.configuration.userContentController removeScriptMessageHandlerForName:@"currentCookies"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
