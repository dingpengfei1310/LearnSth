//
//  HttpManager.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "HttpManager.h"

#import "ResponseModel.h"
#import "TodayModel.h"

#import "AFNetworking.h"

static NSString *BASEURl = @"http://192.168.1.63:8080/td/operate/";

@implementation HttpManager

+ (instancetype)shareManager {
    static HttpManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HttpManager alloc] init];
    });
    
    return manager;
}

- (void)getList {
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASEURl,@"screcommend/getInfo"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *paramString = @"jsonText={'pageno':'1','size':'3'}";
    request.HTTPBody = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dataObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        NSLog(@"%@",dataObject);
        
        ResponseModel *responseModel = [[ResponseModel alloc] init];
        [responseModel setValuesForKeysWithDictionary:dataObject];
        NSLog(@"%@",responseModel.data);
        
        //        NSArray *list = [dataObject objectForKey:@"data"];
        //        NSArray *array = [TodayModel objectWithArray:list];
        //
        //        for (TodayModel *todayModel in array) {
        //            if (todayModel.reason) {
        //                NSLog(@"%@",todayModel.reason);
        //            } else {
        //                NSLog(@"%@",todayModel.contractName);
        //            }
        //        }
        
        
    }];
    [task resume];
}

- (void)getStockData {
    
}

@end
