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

@interface WebViewController ()<WKNavigationDelegate,UIGestureRecognizerDelegate,WKScriptMessageHandler>

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
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

#pragma mark
- (void)setLeftItemsWithCanGoBack:(BOOL)flag {
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -8;
    
    UIImage *image = [UIImage imageNamed:@"backButtonImage"];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(webBackClick)];
    
    if (flag) {
        UIBarButtonItem *spaceItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceItem1.width = -8;
        
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:DDLocalizedString(@"Close") style:UIBarButtonItemStylePlain target:self action:@selector(closeController)];
        
        self.navigationItem.leftBarButtonItems = @[spaceItem,backItem,spaceItem1,closeItem];
    } else {
        self.navigationItem.leftBarButtonItems = @[spaceItem, backItem];
    }
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
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
    
//    [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable title, NSError * _Nullable error) {
//        self.navigationItem.title = title;
//    }];
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
        _KWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, Screen_W, Screen_H)];
        _KWebView.navigationDelegate = self;
//        _KWebView.allowsBackForwardNavigationGestures = YES;//左滑goBack，右滑。。。
        [_KWebView addObserver:self forKeyPath:EstimatedProgress options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return _KWebView;
}

- (WebProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[WebProgressView alloc] initWithFrame:CGRectMake(0, 61 + 0, Screen_W, 3)];
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
