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
    
    [[HttpManager shareManager] getFutureDataWithParamer:nil success:^(id responseData) {
//        NSArray *array = [FuturesModel futureWithArray:responseData];
//        [FuturesModel saveFuturesWithFuturesModelArray:array];
        
    } failure:^(NSError *error) {
        
    }];
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

- (void)scanFileAtPath:(NSString *)filePath {
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *path;
    NSDirectoryEnumerator *myDirectoryEnumerator = [manager enumeratorAtPath:filePath];
    while ((path = [myDirectoryEnumerator nextObject]) != nil) {
        NSLog(@"%@",path);
    }
    
//    NSArray *fileNames =  [manager contentsOfDirectoryAtPath:filePath error:nil];
//    for (NSString *fileName in fileNames) {
//        NSString* fullPath = [filePath stringByAppendingPathComponent:fileName];
//        
//        BOOL flag;
//        if([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&flag]) {
//            if (flag) {
//                [self scanFileAtPath:fullPath];
//                
//            } else {
//                NSLog(@"%@",fileName);
//            }
//            
//        }
        
//    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//    [self scanFileAtPath:doc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
