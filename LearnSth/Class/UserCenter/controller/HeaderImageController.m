//
//  HeaderImageController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/17.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "HeaderImageController.h"
#import "EditImageController.h"

#import "UserManager.h"

#import <FLAnimatedImage.h>
#import <NSData+ImageContentType.h>

#import <AVFoundation/AVFoundation.h>
#import <Photos/PHPhotoLibrary.h>

@interface HeaderImageController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) FLAnimatedImageView *imageView;

@end

@implementation HeaderImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"头像";
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menuList"] style:UIBarButtonItemStylePlain target:self action:@selector(changeHeaderImage)];
    
    CGFloat viewW = CGRectGetWidth(self.view.frame);
    _imageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(0, 64, viewW, self.view.frame.size.height - 64)];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.image = [UIImage imageWithData:[UserManager shareManager].headerImageData];
    
    NSData *data = [UserManager shareManager].headerImageData;
    if (data) {
        if ([NSData sd_imageFormatForImageData:data] == SDImageFormatGIF) {
            _imageView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
        } else {
            _imageView.image = [UIImage imageWithData:data];
        }
    }
    [self.view addSubview:_imageView];
}

#pragma mark
- (void)changeHeaderImage {
    UIAlertController *actionSheet;
    actionSheet = [UIAlertController alertControllerWithTitle:@"上传头像"
                                                      message:nil
                                               preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self checkAuthorizationStatusWithType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self checkAuthorizationStatusWithType:UIImagePickerControllerSourceTypeCamera];
        }];
        [actionSheet addAction:cameraAction];
    }
    
    [actionSheet addAction:cancelAction];
    [actionSheet addAction:albumAction];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)checkAuthorizationStatusWithType:(UIImagePickerControllerSourceType)sourceType {
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {//相机
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if (status == AVAuthorizationStatusAuthorized) {
            [self openUserCameraWithType:sourceType];
            
        } else if (status == AVAuthorizationStatusDenied) {
            [self showAuthorizationStatusDeniedAlertMessage:@"没有相机访问权限"];
            
        } else if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                granted ? [self openUserCameraWithType:sourceType] : 0;
            }];
        }
        
    } else {//相册
        PHAuthorizationStatus currentStatus = [PHPhotoLibrary authorizationStatus];
        
        if (currentStatus == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    status == PHAuthorizationStatusAuthorized ? [self openUserCameraWithType:sourceType] : 0;
                });
            }];
            
        } else if (currentStatus == PHAuthorizationStatusDenied) {
            [self showAuthorizationStatusDeniedAlertMessage:@"没有相册访问权限"];
            
        } else if (currentStatus == PHAuthorizationStatusAuthorized) {
            [self openUserCameraWithType:sourceType];
        }
    }
}

- (void)openUserCameraWithType:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
//    pickerController.allowsEditing = YES;
    pickerController.sourceType = sourceType;
    [self presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
//    UIImage *image = info[UIImagePickerControllerEditedImage];
//    self.imageView.image = image;
//
//    [self dismissViewControllerAnimated:YES completion:^{
//        [UserManager shareManager].headerImageData = UIImagePNGRepresentation(image);
//        [UserManager updateUser];
//        if (self.ChangeHeaderImageBlock) {
//            self.ChangeHeaderImageBlock();
//        }
//    }];
    
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    if (originalImage.imageOrientation != UIImageOrientationUp) {
        UIGraphicsBeginImageContext(originalImage.size);
        [originalImage drawInRect:CGRectMake(0, 0, originalImage.size.width, originalImage.size.height)];
        originalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    EditImageController *controller = [[EditImageController alloc] init];
    controller.originalImage = originalImage;
    controller.FinishImageBlock = ^(UIImage *editImage) {
        if (editImage) {
            [self dismissViewControllerAnimated:YES completion:nil];
            
            self.imageView.image = editImage;
            [UserManager shareManager].headerImageData = UIImagePNGRepresentation(editImage);
            [UserManager updateUser];
            if (self.ChangeHeaderImageBlock) {
                self.ChangeHeaderImageBlock();
            }
        } else {
            if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                [picker dismissViewControllerAnimated:YES completion:nil];
            }
        }
    };
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:controller];
    [picker presentViewController:nvc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
