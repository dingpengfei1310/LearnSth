//
//  UserQRCodeController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/11.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "UserQRCodeController.h"
#import "UIImage+QRCode.h"

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
    
    UIImage *codeImage = [UIImage imageWithQRText:qrString
                                            size:CGRectGetWidth(self.qrImageView.frame)
                                      frontColor:[CIColor colorWithRed:0.8 green:0.3 blue:0.1]
                                       backColor:[CIColor colorWithRed:1.0 green:1.0 blue:1.0]
                                       watermark:[UIImage imageNamed:@"panda"]];
    self.qrImageView.image = codeImage;
}

#pragma mark
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
