//
//  ScanImageController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/2/17.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "ScanQRCodeController.h"
#import "WebViewController.h"
#import "UserQRCodeController.h"

#import <AVFoundation/AVFoundation.h>

@interface ScanQRCodeController ()<AVCaptureMetadataOutputObjectsDelegate> {
    CGFloat scanWidth;
}

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, assign) CGRect scanRect;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UIImageView *lineImageView;

@property (nonatomic, assign) BOOL isAuthorized;

@end

@implementation ScanQRCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"二维码扫描";
    scanWidth = CGRectGetWidth(self.view.frame) * 0.7;
    
    [self checkAuthorizationStatusOnVideo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_isAuthorized) {
        [self.captureSession startRunning];
        [self startDisplayLink];
        
        if (!self.metadataOutput.metadataObjectsDelegate) {
            [self.metadataOutput setMetadataObjectsDelegate:self queue:self.queue];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_isAuthorized) {
        [self.captureSession stopRunning];
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

#pragma mark
- (void)checkAuthorizationStatusOnVideo {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusAuthorized) {
        [self showVideoPreviewLayer];
    } else if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
        [self showAuthorizationStatusDeniedAlertMessage:@"没有相机访问权限"];
        
    } else if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                granted ? [self showVideoPreviewLayer] : 0;
            });
        }];
    }
}

- (void)showVideoPreviewLayer {
    _isAuthorized = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(QRCode)];
    
    //创建一个预览图层
    AVCaptureVideoPreviewLayer *preLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    preLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:preLayer];
    
    [self.captureSession startRunning];
    
    _scanRect = CGRectMake((CGRectGetWidth(self.view.frame) - scanWidth) / 2, (CGRectGetHeight(self.view.frame) - scanWidth) / 2 - CGRectGetWidth(self.view.frame) * 0.1, scanWidth, scanWidth);
    CGRect rectOfInterest = [preLayer metadataOutputRectOfInterestForRect:_scanRect];
    self.metadataOutput.rectOfInterest = rectOfInterest;
    
    [self addMaskViewWithRect:_scanRect];
    
    [self startDisplayLink];
}

- (void)addMaskViewWithRect:(CGRect)scanRect {
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    [maskPath appendPath:[[UIBezierPath bezierPathWithRoundedRect:scanRect cornerRadius:scanWidth * 0.02] bezierPathByReversingPath]];
    maskLayer.path = maskPath.CGPath;
    
    UIView *maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    maskView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    maskView.layer.mask = maskLayer;
    [self.view addSubview:maskView];
    
    _lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(scanRect), CGRectGetMinY(scanRect), CGRectGetWidth(scanRect), CGRectGetWidth(scanRect) * 3.0 / 80)];
    _lineImageView.image = [UIImage imageNamed:@"QRCodeScanningLine"];
    [self.view addSubview:_lineImageView];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(scanRect), CGRectGetMaxY(scanRect), CGRectGetWidth(scanRect), 30)];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = KBaseTextColor;
    tipLabel.font = [UIFont systemFontOfSize:13];
    tipLabel.text = @"放入框中，即可自动扫描";
    [self.view addSubview:tipLabel];
}

- (void)loopLineView {
    if (CGRectGetMaxY(_lineImageView.frame) < CGRectGetMaxY(_scanRect)) {
        CGRect rect = _lineImageView.frame;
        rect.origin.y += 2.0;
        _lineImageView.frame = rect;
    } else {
        CGRect rect = _lineImageView.frame;
        rect.origin.y = CGRectGetMinY(_scanRect);
        _lineImageView.frame = rect;
    }
}

- (void)startDisplayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(loopLineView)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)QRCode {
    UserQRCodeController *controller = [[UserQRCodeController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        NSString *message = obj.stringValue;
        
        [self.metadataOutput setMetadataObjectsDelegate:nil queue:self.queue];
        [self handleScanResult:message];
    }
}

- (void)handleScanResult:(NSString *)result {
    if ([result hasPrefix:@"http"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            WebViewController *controller = [[WebViewController alloc] init];
            controller.urlString = result;
            [self.navigationController pushViewController:controller animated:YES];
        });
    } else {
        [self showAlertWithTitle:@"扫描结果" message:result operationTitle:@"确定" operation:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

#pragma mark
- (dispatch_queue_t)queue {
    if (!_queue) {
        _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return _queue;
}

- (AVCaptureMetadataOutput *)metadataOutput {
    if (!_metadataOutput) {
        _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_metadataOutput setMetadataObjectsDelegate:self queue:self.queue];
    }
    return _metadataOutput;
}

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
        
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
        
        if ([_captureSession canAddInput:deviceInput]) {
            [_captureSession addInput:deviceInput];
        }
        if ([_captureSession canAddOutput:self.metadataOutput]) {
            [_captureSession addOutput:self.metadataOutput];
        }
        
        //这句话必须在后面调用，否则availableMetadataObjectTypes为空
        if ([self.metadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
            //二维码：AVMetadataObjectTypeQRCode
            //条形码：AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code
        }
    }
    return _captureSession;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
