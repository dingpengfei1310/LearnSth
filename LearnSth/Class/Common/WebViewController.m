//
//  WebViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/12.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "WebViewController.h"
#import "WebProgressView.h"
#import "UIViewController+PopAction.h"

#import <WebKit/WebKit.h>
#import <KVOController/KVOController.h>

@interface WebViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *KWebView;
@property (nonatomic, strong) WebProgressView *progressView;

@property (nonatomic, strong) FBKVOController *KVOController;//KVO

@end

static NSString *EstimatedProgress = @"estimatedProgress";

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.urlString) {
//        _urlString = @"https://m.weibo.cn/n/ever丶飞飞";
        self.urlString = [_urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *url = [NSURL URLWithString:self.urlString];
        [self.KWebView loadRequest:[NSURLRequest requestWithURL:url]];
        [self.view addSubview:self.KWebView];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshWebView)];
        
        //进度条
        __weak typeof(self) wSelf = self;
        _KVOController = [FBKVOController controllerWithObserver:self];
        [_KVOController observe:wSelf.KWebView keyPath:EstimatedProgress options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  observer, id  object, NSDictionary<NSString *,id> * change) {
            wSelf.progressView.progress = [change[NSKeyValueChangeNewKey] floatValue];
        }];
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
    [self.KWebView reload];
}

#pragma mark WKNavigationDelegate
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
//    decisionHandler(WKNavigationActionPolicyAllow);
//}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self.progressView removeFromSuperview];
    self.progressView.progress = 0.0;
    [self.navigationController.view addSubview:self.progressView];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.title = webView.title;
//    [webView evaluateJavaScript:@"document.title" completionHandler:^(id title, NSError * error) {
//        self.title = title;
//    }];
//    [webView evaluateJavaScript:@"window.webkit.messageHandlers.currentCookies.postMessage(document.cookie)" completionHandler:nil];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self showSuccess:message.name];
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
        
        _KWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuation];
        _KWebView.navigationDelegate = self;
        _KWebView.UIDelegate = self;
//        _KWebView.allowsBackForwardNavigationGestures = YES;//左滑goBack，右滑。。。
        
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
//    [self.KWebView.configuration.userContentController removeScriptMessageHandlerForName:@"currentCookies"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
