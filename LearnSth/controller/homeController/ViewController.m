//
//  ViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "ViewController.h"
#import "TableViewController.h"

#import "WiFiUploadManager.h"
#import "HttpManager.h"

@interface ViewController () {
    HTTPServer *httpServer;
}

@property (nonatomic, strong) UIImageView *imageView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(wifiUpload:)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 30, 100, 30)];
    label.text = @"Home";
    [self.view addSubview:label];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    [self.view addSubview:_imageView];
    
    [[HttpManager shareManager] getFutureData];
}

- (void) wifiUpload:(id)semder {
    WiFiUploadManager *manager = [WiFiUploadManager shareManager];
    BOOL success = [manager startHTTPServerAtPort:10000];
    
    if (success) {
        NSLog(@"URL = %@:%@",manager.ip,@(manager.port));
        NSLog(@"PATH = %@",manager.savePath);
        [[WiFiUploadManager shareManager] showWiFiPageFrontViewController:self.navigationController];
    }
    
//    TableViewController *controller = [[TableViewController alloc] init];
//    [self.navigationController pushViewController:controller animated:YES];
    
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
