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
#import "TPKeyboardAvoidingScrollView.h"

@interface IDCardViewController ()

@property (strong, nonatomic) UIImageView *cardImageView;

@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *genderField;
@property (nonatomic, strong) UITextField *numField;
@property (nonatomic, strong) UITextField *addressField;

@end

const float margin = 20;

@implementation IDCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"身份证";
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(scanClick)];
    
    [self initSubView];
}

- (void)initSubView {
    TPKeyboardAvoidingScrollView *scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, Screen_W, Screen_H - 64)];
    [self.view addSubview:scrollView];
    
    _cardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(margin, margin, Screen_W - 2 * margin, (Screen_W - 2 * margin) * 0.63)];
    _cardImageView.backgroundColor = KBackgroundColor;
    [scrollView addSubview:_cardImageView];
    
    NSArray *textArray = @[@"姓名:",@"性别:",@"号码:",@"住址:"];
    CGFloat spaceH = 10;
    CGFloat labelH = 35;
    
    for (int i = 0; i < textArray.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(margin, 20 + CGRectGetMaxY(_cardImageView.frame) + (spaceH + labelH) * i, 40, labelH)];
        label.font = [UIFont systemFontOfSize:15];
        label.text = textArray[i];
        [scrollView addSubview:label];
        
        UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(margin + 40, 20 + CGRectGetMaxY(_cardImageView.frame) + (spaceH + labelH) * i, Screen_W - margin * 2 - 40, labelH)];
        field.font = [UIFont systemFontOfSize:16];
        field.borderStyle = UITextBorderStyleRoundedRect;
        [scrollView addSubview:field];
        
        switch (i) {
            case 0:
                _nameField = field;
                break;
            case 1:
                _genderField = field;
                break;
            case 2:
                _numField = field;
                _numField.keyboardType = UIKeyboardTypeASCIICapable;
                break;
            case 3:
                _addressField = field;
                break;
                
            default:
                break;
        }
    }
}

- (void)scanClick {
    if (TARGET_OS_SIMULATOR) {
        [self showError:@"真机使用"];
        return;
    }
    
    ScanIDCardController *controller = [[ScanIDCardController alloc] init];
    controller.ScanResult = ^(IDCardInfo *cardInfo, UIImage *image) {
        self.cardImageView.image = image;
        
        self.nameField.text = cardInfo.name;
        self.genderField.text = cardInfo.gender;
        self.numField.text = cardInfo.num;
        self.addressField.text = cardInfo.address;
    };
    controller.DismissBlock = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
