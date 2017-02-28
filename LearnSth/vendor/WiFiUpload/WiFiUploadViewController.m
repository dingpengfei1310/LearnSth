//
//  WiFiUploadViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/22.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "WiFiUploadViewController.h"
#import "WiFiUploadManager.h"

//#import <SSZipArchive/ZipArchive.h>

@interface WiFiUploadViewController ()

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *ipLabel;

@property (nonatomic, copy) NSString *fileName;

@end

@implementation WiFiUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"WiFi";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    
    [self.view addSubview:self.ipLabel];
    [self.view addSubview:self.progressView];
    
    [self addUploadNotification];
}

#pragma mark
- (void)dismiss {
    WiFiUploadManager *manager = [WiFiUploadManager shareManager];
    [manager stopHTTPServer];
    self.WiFiDismissBlock();
}

- (void)addUploadNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadStart:) name:FileUploadDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadFinish:) name:FileUploadDidEndNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadProgress:) name:FileUploadProgressNotification object:nil];
}

#pragma mark WiFiUploadNotification Callback
- (void)fileUploadStart:(NSNotification *)nof {
    NSString *fileName = nof.object[@"fileName"];
    self.fileName = fileName;
    NSLog(@"Start Upload <%@>",fileName);
}

- (void)fileUploadFinish:(NSNotification *)nof {
    NSLog(@"File Upload Finished.");
    
//    [self showSuccess:@"上传成功"];
    
//    NSString *folder = [WiFiUploadManager shareManager].savePath;
//    NSString *filePath = [folder stringByAppendingPathComponent:self.fileName];
//    [SSZipArchive unzipFileAtPath:filePath toDestination:[WiFiUploadManager shareManager].savePath delegate:self];
}

- (void)fileUploadProgress:(NSNotification *)nof {
    CGFloat progress = [nof.object[@"progress"] doubleValue];
    self.progressView.progress = progress;
}

#pragma mark ZipNotification
- (void)zipArchiveProgressEvent:(unsigned long long)loaded total:(unsigned long long)total {
    self.progressView.progress = loaded * 1.0 / total;
}

#pragma mark
- (UILabel *)ipLabel {
    if (!_ipLabel) {
        WiFiUploadManager *manager = [WiFiUploadManager shareManager];
        
        CGRect rect = CGRectMake(20, 100, CGRectGetWidth(self.view.frame) - 40, 40);
        _ipLabel = [[UILabel alloc] initWithFrame:rect];
        _ipLabel.font = [UIFont systemFontOfSize:16];
        _ipLabel.numberOfLines = 0;
        _ipLabel.textAlignment = NSTextAlignmentCenter;
        _ipLabel.layer.masksToBounds = YES;
        _ipLabel.layer.cornerRadius = 5;
        _ipLabel.backgroundColor = [UIColor grayColor];
        _ipLabel.textColor = [UIColor whiteColor];
        _ipLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _ipLabel.text = [NSString stringWithFormat:@"http://%@:%@",manager.ip,@(manager.port)];
    }
    
    return _ipLabel;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        CGRect rect = CGRectMake(20, 180, CGRectGetWidth(self.view.frame) - 40, 20);
        _progressView = [[UIProgressView alloc] initWithFrame:rect];
        _progressView.progress = 0;
    }
    return _progressView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
