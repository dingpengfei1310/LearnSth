//
//  ViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "ViewController.h"

#import "WiFiUploadManager.h"
#import "HttpManager.h"

#import "FuturesModel.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(wifiUpload:)];
    
//    [[HttpManager shareManager] getFutureDataWithParamer:nil success:^(id responseData) {
////        NSArray *array = [FuturesModel futureWithArray:responseData];
////        [FuturesModel saveFuturesWithFuturesModelArray:array];
////        NSLog(@"%@",responseData[0]);
//    } failure:^(NSError *error) {
//        
//    }];
    
}

- (void) wifiUpload:(id)semder {
    WiFiUploadManager *manager = [WiFiUploadManager shareManager];
    BOOL success = [manager startHTTPServerAtPort:10000];
    
    if (success) {
        NSLog(@"URL = %@:%@",manager.ip,@(manager.port));
        NSLog(@"PATH = %@",manager.savePath);
        [[WiFiUploadManager shareManager] showWiFiPageViewController:self.navigationController];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
