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
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UILabel *fileNameLabel;

@property (nonatomic, strong) NSString *fileName;

@end

@implementation WiFiUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WiFi";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissWiFiController)];
    
    [self.view addSubview:self.ipLabel];
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.progressLabel];
    [self.view addSubview:self.fileNameLabel];
    
    [self addUploadNotification];
}

#pragma mark
- (void)dismissWiFiController {
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
    _fileNameLabel.text = fileName;
}

- (void)fileUploadFinish:(NSNotification *)nof {
    self.progressView.progress = 1.0;
    _progressLabel.text = @"100.0%";
    [self showSuccess:@"上传成功"];
    
//    NSString *folder = [WiFiUploadManager shareManager].savePath;
//    NSString *filePath = [folder stringByAppendingPathComponent:self.fileName];
//    [SSZipArchive unzipFileAtPath:filePath toDestination:[WiFiUploadManager shareManager].savePath delegate:self];
}

- (void)fileUploadProgress:(NSNotification *)nof {
    CGFloat progress = [nof.object[@"progress"] doubleValue];
    self.progressView.progress = progress;
    _progressLabel.text = [NSString stringWithFormat:@"%.1f%%",progress * 100];
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
        _ipLabel.textAlignment = NSTextAlignmentCenter;
        _ipLabel.layer.masksToBounds = YES;
        _ipLabel.layer.cornerRadius = 3;
        _ipLabel.backgroundColor = [UIColor lightGrayColor];
        _ipLabel.textColor = [UIColor whiteColor];
        _ipLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _ipLabel.text = [NSString stringWithFormat:@"http://%@:%@",manager.ip,@(manager.port)];
    }
    
    return _ipLabel;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        CGRect rect = CGRectMake(20, CGRectGetMaxY(_ipLabel.frame) + 30 + 14, CGRectGetWidth(self.view.frame) - 100, 2);
        _progressView = [[UIProgressView alloc] initWithFrame:rect];
        _progressView.progress = 0;
    }
    return _progressView;
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        CGRect rect = CGRectMake(CGRectGetMaxX(_progressView.frame), CGRectGetMaxY(_ipLabel.frame) + 30, 60, 30);
        _progressLabel = [[UILabel alloc] initWithFrame:rect];
        _progressLabel.textAlignment = NSTextAlignmentRight;
        _progressLabel.font = [UIFont systemFontOfSize:16];
        _progressLabel.textColor = [UIColor blackColor];
        _progressLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _progressLabel.text = @"0.0%";
    }
    return _progressLabel;
}

- (UILabel *)fileNameLabel {
    if (!_fileNameLabel) {
        CGRect rect = CGRectMake(20, CGRectGetMaxY(_progressView.frame) + 30, CGRectGetWidth(self.view.frame) - 40, 30);
        _fileNameLabel.backgroundColor = [UIColor lightGrayColor];
        _fileNameLabel = [[UILabel alloc] initWithFrame:rect];
        _fileNameLabel.font = [UIFont systemFontOfSize:15];
        _fileNameLabel.textColor = [UIColor blackColor];
        _fileNameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }
    return _fileNameLabel;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
