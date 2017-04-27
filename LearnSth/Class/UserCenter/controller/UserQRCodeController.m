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

@property (weak, nonatomic) IBOutlet UITextField *qrTextField;
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;

@end

@implementation UserQRCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"二维码生成";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(QRCodeCreate)];
}

- (void)QRCodeCreate {
    [self.view endEditing:YES];
    
    NSString *qrString = [self.qrTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (qrString.length == 0) {
        [self showError:@"输入正确的文字"];
        return;
    }
    
//    UIImage *codeImage = [UIImage imageWithText:qrString
//                                           size:CGRectGetWidth(self.qrImageView.frame)
//                                      watermark:[UIImage imageNamed:@"panda"]];
//    self.qrImageView.image = codeImage;
    
    QRCodeGenerator *generator = [[QRCodeGenerator alloc] init];
    generator.content = qrString;
    generator.codeWidth = CGRectGetWidth(self.qrImageView.frame);
//    generator.codeWidth = CGRectGetWidth(self.qrImageView.frame);
    generator.icon = [UIImage imageNamed:@"panda"];
    self.qrImageView.image = [generator QRCodeImage];
}

#pragma mark
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
