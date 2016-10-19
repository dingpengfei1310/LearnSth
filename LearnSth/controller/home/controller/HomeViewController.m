//
//  ViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "HomeViewController.h"
#import "WebViewController.h"

#import "HttpRequestManager.h"

#import "UserModel.h"
#import "ADModel.h"

#import "SDCycleScrollView.h"

@interface HomeViewController ()<SDCycleScrollViewDelegate>

@property (nonatomic, strong) NSArray *adList;

@end

static NSString *identifier = @"cell";

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
}

- (void)topAdBanner {
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 64, ScreenWidth,ScreenWidth * 0.24)
                                                                            delegate:self placeholderImage:nil];
    cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    cycleScrollView.currentPageDotColor = [UIColor whiteColor]; // 自定义分页控件小圆标颜色
    [self.view addSubview:cycleScrollView];
    
    [[HttpRequestManager shareManager] getADListWithParamer:nil success:^(id responseData) {
        
        self.adList = [ADModel adWithArray:responseData];
        
        NSMutableArray *imageUrls = [NSMutableArray arrayWithCapacity:self.adList.count];
        for (ADModel *topAD in self.adList) {
            [imageUrls addObject:topAD.imageUrl];
        }
        
        cycleScrollView.imageURLStringsGroup = imageUrls;
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    ADModel *model = self.adList[index];
    
    WebViewController *controller = [[WebViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.urlString = model.link;
    [self.navigationController pushViewController:controller animated:YES];
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
