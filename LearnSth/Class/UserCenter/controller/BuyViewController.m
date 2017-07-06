//
//  BuyViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/6/30.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "BuyViewController.h"
#import <StoreKit/StoreKit.h>

@interface BuyViewController ()<SKProductsRequestDelegate>

@end

@implementation BuyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(buySth)];
}

- (void)buySth {
//    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    [self showAlertWithTitle:nil message:@"确定购买吗" cancel:nil operation:^{
//        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        
        if([SKPaymentQueue canMakePayments]) {
            NSString *product = @"123";
            [self requestProductData:product];
        } else {
            NSLog(@"不允许程序内付费");
        }
    }];
}

//请求商品
- (void)requestProductData:(NSString *)type {
    NSArray *product = [[NSArray alloc] initWithObjects:type,nil];
    
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];
    
    [self loading];
}

#pragma mark - 产品返回信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    [self hideHUD];
    
    NSArray *product = response.products;
    if([product count] == 0){
        [self showError:@"没有商品"];
        return;
    }
    
    NSLog(@"productID:%@", response.invalidProductIdentifiers);
    NSLog(@"产品付费数量:%lu",(unsigned long)[product count]);
    
    SKProduct *p = nil;
    for (SKProduct *pro in product) {
        NSLog(@"%@", [pro description]);
        NSLog(@"%@", [pro localizedTitle]);
        NSLog(@"%@", [pro localizedDescription]);
        NSLog(@"%@", [pro price]);
        NSLog(@"%@", [pro productIdentifier]);
        
//        if([pro.productIdentifier isEqualToString:_currentProId]){
//            p = pro;
//        }
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:p];
    
    NSLog(@"发送购买请求");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark -
//- (void)payment

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
