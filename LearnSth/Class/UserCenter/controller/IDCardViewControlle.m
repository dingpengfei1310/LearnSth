//
//  UserIDInfoController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/10.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "IDCardViewController.h"
#import "ScanIDCardController.h"
#import "IDCardInfo.h"

@interface IDCardViewControlle ()

@property (weak, nonatomic) IBOutlet UIImageView *cardImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end

@implementation IDCardViewControlle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(scanClick)];
    self.cardImageView.backgroundColor = KBackgroundColor;
}

- (void)scanClick {
    if (TARGET_OS_SIMULATOR) {
        [self showError:@"真机使用"];
        return;
    }
    
    ScanIDCardController *controller = [[ScanIDCardController alloc] init];
    controller.ScanResult = ^(IDCardInfo *cardInfo, UIImage *image) {
        self.cardImageView.image = image;
        
        self.nameLabel.text = [NSString stringWithFormat:@"姓名：%@",cardInfo.name];
        self.genderLabel.text = [NSString stringWithFormat:@"性别：%@",cardInfo.gender];
        self.cardNumLabel.text = [NSString stringWithFormat:@"号码：%@",cardInfo.num];
        self.addressLabel.text = [NSString stringWithFormat:@"住址：%@",cardInfo.address];
    };
    controller.DismissBlock = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
