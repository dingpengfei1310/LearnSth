//
//  ScanImageController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/2/17.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "ScanQRCodeController.h"
#import <AVFoundation/AVFoundation.h>
#import "WebViewController.h"

@interface ScanQRCodeController ()<AVCaptureMetadataOutputObjectsDelegate> {
    CGFloat scanWidth;
}

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation ScanQRCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"二维码";
    scanWidth = Screen_W * 0.6;
    
    [self checkAuthorizationStatusOnVideo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.metadataOutput.metadataObjectsDelegate) {
        [self.metadataOutput setMetadataObjectsDelegate:self queue:self.queue];
    }
}

- (void)checkAuthorizationStatusOnVideo {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusAuthorized) {
        [self showVideoPreviewLayer];
    } else if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
        [self showAuthorizationStatusDeniedAlertMessage:@"没有相机访问权限" cancel:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        } operation:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
    } else if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                granted ? [self showVideoPreviewLayer] : [self dismissViewControllerAnimated:YES completion:nil];
            });
        }];
    }
}

- (void)showVideoPreviewLayer {
    //创建一个预览图层
    AVCaptureVideoPreviewLayer *preLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    preLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:preLayer];
    
    [self.captureSession startRunning];
    
    CGRect scanRect = CGRectMake((Screen_W - scanWidth) / 2, (Screen_H - scanWidth) / 2, scanWidth, scanWidth);
    CGRect rectOfInterest = [preLayer metadataOutputRectOfInterestForRect:scanRect];
    self.metadataOutput.rectOfInterest = rectOfInterest;
    
    [self addMaskViewWithRect:scanRect];
}

- (void)addMaskViewWithRect:(CGRect)scanRect {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, Screen_W, Screen_H)];
    [maskPath appendPath:[[UIBezierPath bezierPathWithRoundedRect:scanRect cornerRadius:1] bezierPathByReversingPath]];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.path = maskPath.CGPath;
    
    UIView *maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    maskView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.6];
    maskView.layer.mask = maskLayer;
    [self.view addSubview:maskView];
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
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
        
        //将输入输出设备添加到会话中
        if ([_captureSession canAddInput:videoDeviceInput]) {
            [_captureSession addInput:videoDeviceInput];
        }
        if ([_captureSession canAddOutput:self.metadataOutput]) {
            [_captureSession addOutput:self.metadataOutput];
        }
        
        //这句话必须在后面调用，否则availableMetadataObjectTypes为空
        if ([self.metadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        }
        
    }
    return _captureSession;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
