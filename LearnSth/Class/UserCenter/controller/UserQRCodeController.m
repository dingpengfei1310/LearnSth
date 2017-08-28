//
//  UserQRCodeController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/11.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "UserQRCodeController.h"
#import "UIImage+QRCode.h"
#import "QRCodeGenerator.h"

@interface UserQRCodeController ()

@property (strong, nonatomic) UITextField *qrTextField;
@property (strong, nonatomic) UIImageView *qrImageView;

@end

@implementation UserQRCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"二维码生成";
    self.view.backgroundColor = KBackgroundColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(QRCodeCreate)];
    
    [self initSubView];
}

- (void)initSubView {
    _qrTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 64 + 20, self.view.frame.size.width - 40, 35)];
    _qrTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:_qrTextField];
    
    _qrImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 20 + CGRectGetMaxY(_qrTextField.frame), self.view.frame.size.width - 100, self.view.frame.size.width - 100)];
    _qrImageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_qrImageView];
}

- (void)QRCodeCreate {
    [self.view endEditing:YES];
    
    NSString *qrString = [self.qrTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (qrString.length == 0) {
        [self showError:@"输入正确的文字"];
        return;
    }
    
//    CIColor *color = [CIColor colorWithRed:0.0 green:1.0 blue:1.0];
//    UIImage *codeImage = [UIImage imageWithText:qrString
//                                           size:CGRectGetWidth(self.qrImageView.frame)
//                                      frontColor:nil
//                                      backColor:color];
//    self.qrImageView.image = codeImage;
    
    QRCodeGenerator *generator = [[QRCodeGenerator alloc] init];
    generator.content = qrString;
    generator.codeWidth = CGRectGetWidth(self.qrImageView.frame);
    generator.backgroundColor = [UIColor clearColor];
//    generator.watermark = [UIImage imageNamed:@"panda"];
    self.qrImageView.image = [generator QRCodeImage];
    
    //渐变色二维码（必须透明背景色）
//    CALayer *maskLayer = [CALayer layer];
//    maskLayer.frame = self.qrImageView.bounds;
////    maskLayer.contents = (id)codeImage.CGImage;
//    
//    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//    gradientLayer.frame = self.qrImageView.bounds;
//    gradientLayer.colors = @[(id)[UIColor redColor].CGColor,
//                             (id)[UIColor greenColor].CGColor,
//                             (id)[UIColor blueColor].CGColor];
//    gradientLayer.mask = maskLayer;
//    [self.qrImageView.layer addSublayer:gradientLayer];
}

#pragma mark
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
