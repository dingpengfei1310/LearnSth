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

@interface WiFiUploadViewController () {
    CGFloat viewW;
}

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
    
    viewW = CGRectGetWidth(self.view.frame);
    WiFiUploadManager *manager = [WiFiUploadManager shareManager];
    
    CGRect rect = CGRectMake(20, 100, viewW - 40, 40);
    _ipLabel = [[UILabel alloc] initWithFrame:rect];
    _ipLabel.textAlignment = NSTextAlignmentCenter;
    _ipLabel.layer.masksToBounds = YES;
    _ipLabel.layer.cornerRadius = 3;
    _ipLabel.backgroundColor = KBackgroundColor;
    _ipLabel.textColor = KBaseAppColor;
    _ipLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _ipLabel.text = [NSString stringWithFormat:@"http://%@:%@",manager.ip,@(manager.port)];
    [self.view addSubview:_ipLabel];
    
    [self addUploadNotification];
}

- (void)loadSubView {
    _fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_ipLabel.frame) + 20, viewW * 0.5 - 20, 30)];
    _fileNameLabel.adjustsFontSizeToFitWidth = YES;
    _fileNameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    _fileNameLabel.textColor = KBaseTextColor;
    _fileNameLabel.text = @"--";
    
    _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewW * 0.5, CGRectGetMaxY(_ipLabel.frame) + 20, viewW * 0.5, 30)];
    _progressLabel.textAlignment = NSTextAlignmentCenter;
    _progressLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    _progressLabel.textColor = KBaseTextColor;
    _progressLabel.text = @"0.0%";
    _progressLabel.text = @"上传成功";
    
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_fileNameLabel.frame) + 10, viewW - 40, 2)];
    _progressView.tintColor = [UIColor colorWithRed:250/255.0 green:30/255.0 blue:80/255.0 alpha:1.0];
    _progressView.progress = 0;
    
    [self.view addSubview:self.fileNameLabel];
    [self.view addSubview:self.progressLabel];
    [self.view addSubview:self.progressView];
}

#pragma mark
- (void)dismissWiFiController {
    [[WiFiUploadManager shareManager] stopHTTPServer];
    self.WiFiDismissBlock();
}

- (void)addUploadNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadStart:) name:WiFiUploadManagerDidStart object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadProgress:) name:WiFiUploadManagerProgress object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadFinish:) name:WiFiUploadManagerDidEnd object:nil];
}

#pragma mark - WiFiUploadNotification Callback
- (void)fileUploadStart:(NSNotification *)nof {
    if (!_fileNameLabel) {
        [self loadSubView];
    }
    NSString *fileName = nof.object[@"fileName"];
    self.fileName = fileName;
    self.fileNameLabel.text = fileName;
}

- (void)fileUploadFinish:(NSNotification *)nof {
    self.progressView.progress = 1.0;
    self.progressLabel.text = @"上传成功";
    
//    NSString *folder = [WiFiUploadManager shareManager].savePath;
//    NSString *filePath = [folder stringByAppendingPathComponent:self.fileName];
//    [SSZipArchive unzipFileAtPath:filePath toDestination:[WiFiUploadManager shareManager].savePath delegate:self];
}

- (void)fileUploadProgress:(NSNotification *)nof {
    CGFloat progress = [nof.object[@"progress"] doubleValue];
    self.progressView.progress = progress;
    self.progressLabel.text = [NSString stringWithFormat:@"%.1f%%",progress * 100];
}

#pragma mark - ZipNotification
- (void)zipArchiveProgressEvent:(unsigned long long)loaded total:(unsigned long long)total {
    self.progressView.progress = loaded * 1.0 / total;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
