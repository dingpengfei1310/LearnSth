//
//  HttpManager.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "HttpRequestManager.h"

#import "AFNetworking.h"
#import "SQLManager.h"

static NSString *BASEURl = @"http://192.168.1.63:8080/td/operate/";

@implementation HttpRequestManager

+ (instancetype)shareManager {
    static HttpRequestManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HttpRequestManager alloc] init];
    });
    
    return manager;
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
    
    NSDictionary *parameters = @{@"pageno":@"1",@"size":@"1000",
                                 @"dataType":@"F,S",@"dateTime":@""};
    
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

- (void)getADListWithParamer:(NSDictionary *)paramer success:(Success)success failure:(Failure)failure {
    NSString * urlString = @"http://live.9158.com/Living/GetAD";
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSMutableSet *multSet = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
    [multSet addObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithSet:multSet];
    
    [manager GET:urlString parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *array = [responseObject objectForKey:@"data"];
        success(array);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        success(error);
        NSLog(@"%@", error);
    }];
}

- (void)getHotLiveListWithParamer:(NSDictionary *)paramer success:(Success)success failure:(Failure)failure {
    NSString * urlString = @"http://live.9158.com/Fans/GetHotLive";
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSMutableSet *multSet = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
    [multSet addObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithSet:multSet];
    
    [manager GET:urlString parameters:@{@"page":@"1"} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *array = [[responseObject objectForKey:@"data"] objectForKey:@"list"];
        success(array);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (void)getUserListWithParamer:(NSDictionary *)paramer success:(Success)success failure:(Failure)failure {
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASEURl,@"scgroup/getrank"];
    
    NSDictionary *parameters = @{@"pageno":@"1",@"size":@"10"};
    
    NSString *jsonString = [self JsonModel:parameters];
    NSDictionary *param = @{@"jsonText": jsonString};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:urlString parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *userArray = [responseObject objectForKey:@"data"];
        success(userArray);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}


#pragma mark
- (NSString *)JsonModel:(NSDictionary *)dictModel {
    if ([NSJSONSerialization isValidJSONObject:dictModel]) {
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictModel options:NSJSONWritingPrettyPrinted error:nil];
        NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonStr;
    }
    return nil;
}


@end




