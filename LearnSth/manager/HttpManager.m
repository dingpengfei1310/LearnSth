//
//  HttpManager.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "HttpManager.h"

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

- (void)getWithUrlString:(NSString *)urlString paramets:(NSDictionary *)paramets success:(Success)success failure:(Failure)failure {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSMutableSet *multSet = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
    [multSet addObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithSet:multSet];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:urlString
      parameters:paramets
        progress:^(NSProgress * _Nonnull uploadProgress) {}
         success:^(NSURLSessionDataTask *task, id responseObject) {
             success(responseObject);
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             failure(error);
         }];
}

#pragma mark
- (void)getAdBannerListSuccess:(Success)success failure:(Failure)failure {
    NSString * urlString = @"http://live.9158.com/Living/GetAD";
    
    [self getWithUrlString:urlString paramets:nil success:^(id responseData) {
        NSArray *array = [responseData objectForKey:@"data"];
        success(array);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)getAdBannerListCompletion:(SuccessArray)completion {
    NSString * urlString = @"http://live.9158.com/Living/GetAD";
    
    [self getWithUrlString:urlString paramets:nil success:^(id responseData) {
        NSArray *array = [responseData objectForKey:@"data"];
        completion(array,nil);
    } failure:^(NSError *error) {
        completion(nil,error);
    }];
}

- (void)getHotLiveListWithParamers:(NSDictionary *)paramers completion:(SuccessArray)completion {
    NSString * urlString = @"http://live.9158.com/Fans/GetHotLive";
    [self getWithUrlString:urlString paramets:@{@"page":@"1"} success:^(id responseData) {
        NSArray *array = [[responseData objectForKey:@"data"] objectForKey:@"list"];
        completion(array,nil);
    } failure:^(NSError *error) {
        completion(nil,error);
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




