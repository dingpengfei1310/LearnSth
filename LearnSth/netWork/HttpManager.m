//
//  HttpManager.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "HttpManager.h"

#import "TodayModel.h"

#import "AFNetworking.h"

#import "SQLManager.h"

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
//    NSString *paramString = @"jsonText={'pageno':'1','size':'3'}";
//    request.HTTPBody = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dataObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        NSArray *list = [dataObject objectForKey:@"data"];
        NSArray *array = [TodayModel objectWithArray:list];
        
    }];
    
    [task resume];
}

- (void)getStockDataWithParamer:(NSDictionary *)paramer success:(Success)success failure:(Failure)failure {
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASEURl,@"scstock/getScStock"];
    
    NSDictionary *parameters = @{
                                 @"dateTime":@"",
                                 @"pageno":@"1",
                                 @"size":@"10",
                                 @"dataType":@"0"
                                 };
    
    NSString *jsonString = [self JsonModel:parameters];
    NSDictionary *param = @{@"jsonText": jsonString};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:urlString parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [responseObject objectForKey:@"scStock"];
        success(array);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (void)getFutureDataWithParamer:(NSDictionary *)paramer success:(Success)success failure:(Failure)failure {
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASEURl,@"scfutures/getScFutures"];
    
    NSDictionary *parameters = @{
                                 @"dateTime":@"",
                                 @"pageno":@"1",
                                 @"size":@"1000",
                                 @"dataType":@"F,S"
                                 };
    
    NSString *jsonString = [self JsonModel:parameters];
    NSDictionary *param = @{@"jsonText": jsonString};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:urlString parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *dataArray = [responseObject objectForKey:@"scFutures"];
        success(dataArray);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (NSString *)JsonModel:(NSDictionary *)dictModel {
    if ([NSJSONSerialization isValidJSONObject:dictModel]) {
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictModel options:NSJSONWritingPrettyPrinted error:nil];
        NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonStr;
    }
    return nil;
}


@end




