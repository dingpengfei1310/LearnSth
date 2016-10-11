//
//  ViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "HomeViewController.h"

#import "UIImageView+WebCache.h"
#import "HttpRequestManager.h"
#import "UserModel.h"

#import "UserListViewCell.h"

@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *userList;

@end

static NSString *identifier = @"cell";

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64)
                                              style:UITableViewStylePlain];
    [_tableView registerClass:[UserListViewCell class] forCellReuseIdentifier:identifier];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 50;
    [self.view addSubview:_tableView];
    
    [[HttpRequestManager shareManager] getUserListWithParamer:nil success:^(id responseData) {
        self.userList = [UserModel userWithArray:responseData];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
    
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    UserModel *user = self.userList[indexPath.row];
    cell.titleLabel.text = user.userName;
    cell.subTitleLabel.text = user.groupName;
    
    cell.headerImageView.layer.masksToBounds = YES;
    cell.headerImageView.layer.cornerRadius = 15;
    
    [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:user.image]
                            placeholderImage:[UIImage imageNamed:@"lookup"]];
    
    return cell;
}

- (UIImage *)cornerImage:(UIImage *)originalImage {
    CGRect rect = CGRectMake(0, 0, originalImage.size.width, originalImage.size.height);
    
    UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, [UIScreen mainScreen].scale);
    
    UIBezierPath *bezierPath =  [UIBezierPath bezierPathWithRoundedRect:rect
                                                      byRoundingCorners:UIRectCornerAllCorners
                                                            cornerRadii:originalImage.size];
    
    CGContextAddPath(UIGraphicsGetCurrentContext(), bezierPath.CGPath);
    CGContextClip(UIGraphicsGetCurrentContext());
    [originalImage drawInRect:rect];
    
    CGContextDrawPath(UIGraphicsGetCurrentContext(), kCGPathFill);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSLog(@"%@ - %@",string,textField.textInputMode.primaryLanguage);
    
    if (!textField.textInputMode.primaryLanguage) {
        return NO;
    } else if (string.length > 1) {
        return ![self stringContainsEmoji:string];
    }
    
    return YES;
}

- (BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
