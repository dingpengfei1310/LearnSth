//
//  WiFiUploadViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/22.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "WiFiUploadViewController.h"
#import "WiFiUploadManager.h"

@interface WiFiUploadViewController ()

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation WiFiUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WiFi";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    
    WiFiUploadManager *manager = [WiFiUploadManager shareManager];
    
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 114, self.view.frame.size.width - 40, 30)];
    addressLabel.numberOfLines = 0;
    addressLabel.textAlignment = NSTextAlignmentCenter;
    addressLabel.layer.masksToBounds = YES;
    addressLabel.layer.cornerRadius = 5;
    addressLabel.backgroundColor = [UIColor purpleColor];
    addressLabel.textColor = [UIColor whiteColor];
    addressLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    addressLabel.text = [NSString stringWithFormat:@"http://%@:%@",manager.ip,@(manager.port)];
    [self.view addSubview:addressLabel];
    
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(addressLabel.frame) + 20, self.view.frame.size.width - 40, 20)];
    _progressView.progress = 0;
    [self.view addSubview:_progressView];
    
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_progressView.frame) + 20, self.view.frame.size.width - 40, 30)];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _tipLabel.text = @"上传成功";
    _tipLabel.hidden = YES;
    [self.view addSubview:_tipLabel];
    
    [self addUploadNotification];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addUploadNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadStart:) name:FileUploadDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadFinish:) name:FileUploadDidEndNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadProgress:) name:FileUploadProgressNotification object:nil];
}

#pragma mark Notification Callback
- (void)fileUploadStart:(NSNotification *)nof {
    NSString *fileName = nof.object[@"fileName"];
    NSLog(@"Start Upload <%@>",fileName);
}

- (void)fileUploadFinish:(NSNotification *)nof {
    NSLog(@"File Upload Finished.");
    
    _tipLabel.hidden = NO;
}

- (void)fileUploadProgress:(NSNotification *)nof {
    CGFloat progress = [nof.object[@"progress"] doubleValue];
    _progressView.progress = progress;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
