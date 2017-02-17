//
//  ScanImageController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/2/17.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "ScanImageController.h"
#import <AVFoundation/AVFoundation.h>

@interface ScanImageController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;

@end

@implementation ScanImageController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkAuthorizationStatusOnVideo];
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
            granted ? [self showVideoPreviewLayer] : [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

- (void)showVideoPreviewLayer {
    //创建一个预览图层
    AVCaptureVideoPreviewLayer *preLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    preLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:preLayer];
    
    [self.captureSession startRunning];
}

#pragma mark
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    [self.captureSession stopRunning];
    
    NSString *val = nil;
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        val = obj.stringValue;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self showSuccess:val];
            NSLog(@"%@",val);
        });
    }
}

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        
        AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc]init];
        dispatch_queue_t dispatchQueue = dispatch_queue_create("myQueue", NULL);
        [metadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
        
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
        
        //将输入输出设备添加到会话中
        if ([_captureSession canAddInput:videoDeviceInput]) {
            [_captureSession addInput:videoDeviceInput];
        }
        if ([_captureSession canAddOutput:metadataOutput]) {
            [_captureSession addOutput:metadataOutput];
        }
        
        //这句话必须在后面调用，否则availableMetadataObjectTypes为空
        metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    }
    return _captureSession;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
