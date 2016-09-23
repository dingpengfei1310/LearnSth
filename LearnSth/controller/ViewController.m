//
//  ViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "ViewController.h"

#import "WiFiUploadManager.h"

@interface ViewController () {
    HTTPServer *httpServer;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(wifiUpload:)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 30, 100, 30)];
    label.text = @"Home";
    [self.view addSubview:label];
}

- (void) wifiUpload:(id)semder {
//    WiFiUploadManager *manager = [WiFiUploadManager shareManager];
//    BOOL success = [manager startHTTPServerAtPort:10000];
//    
//    if (success) {
//        NSLog(@"URL = %@:%@",manager.ip,@(manager.port));
//        NSLog(@"PATH = %@",manager.savePath);
//        [[WiFiUploadManager shareManager] showWiFiPageFrontViewController:self.navigationController];
//    }
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
