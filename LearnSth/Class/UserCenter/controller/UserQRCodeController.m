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
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(QRCodeCreate)];
    
    [self initSubView];
}

- (void)initSubView {
    _qrTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 20, Screen_W - 40, 35)];
    _qrTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:_qrTextField];
    
    _qrImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 20 + CGRectGetMaxY(_qrTextField.frame), Screen_W - 100, Screen_W - 100)];
    [self.view addSubview:_qrImageView];
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
//    generator.watermark = [UIImage imageNamed:@"panda"];
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
